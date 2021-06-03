$azureuser = az ad user list --display-name "Alexandre Teoi" --query [0].userPrincipalName
$azuresubscription = "fcb2616f-096b-4e78-b6ee-72db022919b0"
$resourcegroup = "rg-eshoponweb"
$storageaccountname = "stdeploych001"
$sqlservername = "sql-eshoponweb-ch-001"
$scalesetname = "vmss-web-ch-001"
$autoscalename = "vmssas-web-ch-001"
$adminusername = "eshopadmin"
$sqladminpassword = "s3nh@Comple*4"

az login

# Resource Group
az group create -l brazilsouth -n $resourcegroup

# Storage
az storage account create -g $resourcegroup -n $storageaccountname -l brazilsouth --sku Standard_LRS --encryption-services blob
az ad signed-in-user show --query objectId -o tsv | az role assignment create --role "Storage Blob Data Contributor" --assignee $azureuser --scope "/subscriptions/$azuresubscription/resourceGroups/$resourcegroup/providers/Microsoft.Storage/storageAccounts/$storageaccountname"
az storage container create -n stcdeploych001 --account-name $storageaccountname --public-access off --auth-mode login
az storage share create -n products --quota 10 --account-name $storageaccountname
az storage share create -n dataprotection --quota 10 --account-name $storageaccountname
az storage account keys list -g $resourcegroup -n $storageaccountname

# Azure SQL Database
az sql server create -g $resourcegroup -n $sqlservername -l brazilsouth --admin-user $adminusername --admin-password $sqladminpassword
az sql server firewall-rule create -g $resourcegroup -n sqlfw-allowazureips-ch-001 -s $sqlservername --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az sql db create -g $resourcegroup -n Microsoft.eShopOnWeb.CatalogDb -s $sqlservername -e Basic
az sql db create -g $resourcegroup -n Microsoft.eShopOnWeb.Identity -s $sqlservername -e Basic

# VM Scale Set
az vmss create -g $resourcegroup -n $scalesetname --image UbuntuLTS --upgrade-policy-mode automatic --admin-username $adminusername --generate-ssh-keys
## DNS Name
$publicip = az network public-ip list -g $resourcegroup --query "[?contains(name, '$scalesetname')].name" | ConvertFrom-Json
az network public-ip update -g $resourcegroup -n $publicip --dns-name eshoponwebch001
## Application deployment
az vmss extension set -g $resourcegroup -n CustomScript --publisher Microsoft.Azure.Extensions --version 2.0 --vmss-name $scalesetname --settings .\script-config.json --protected-settings .\protected-config.json
## Load Balancer configuration
$loadbalancer = az network lb list -g $resourcegroup --query "[?contains(name, '$scalesetname')].name" | ConvertFrom-Json
az network lb probe create -g $resourcegroup -n healtchecks --lb-name $loadbalancer --protocol http --port 80 --path /health
az network lb rule create -g $resourcegroup -n lbr-web-ch-001 --lb-name $loadbalancer --backend-pool-name "$($scalesetname)LBBEPool" --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --probe-name healthchecks
## Autoscale
az monitor autoscale create -g $resourcegroup -n $autoscalename --resource $scalesetname --resource-type Microsoft.Compute/virtualMachineScaleSets --min-count 2 --max-count 3 --count 2
az monitor autoscale rule create -g $resourcegroup --autoscale-name $autoscalename --condition "Percentage CPU > 70 avg 5m" --scale out 1
az monitor autoscale rule create -g $resourcegroup --autoscale-name $autoscalename --condition "Percentage CPU < 30 avg 5m" --scale in 1
