param ([Parameter(Mandatory = $true)]$environment, [Parameter(Mandatory = $true)]$username, [Parameter(Mandatory = $true)]$azuresubscription)

$azureuser = az ad user list --display-name $username --query [0].userPrincipalName
$resourcegroup = "rg-eshoponweb-$environment"
$storageaccountname = "stdeploy$environment"
$storagecontainername = "stcdeploy$environment"
$sqlservername = "sql-eshoponweb-$environment"
$scalesetname = "vmss-web-$environment"
$autoscalename = "vmssas-web-$environment"
$dnsName = "eshoponweb-$environment"
$adminusername = "eshopadmin"
$sqladminpassword = "s3nh@Comple*4"

az login

# Resource Group
az group create -l brazilsouth -n $resourcegroup --subscription $azuresubscription

# Storage
az storage account create --subscription $azuresubscription -g $resourcegroup -n $storageaccountname -l brazilsouth --sku Standard_LRS --encryption-services blob 
az ad signed-in-user show --query objectId -o tsv | az role assignment create --role "Storage Blob Data Contributor" --assignee $azureuser --scope "/subscriptions/$azuresubscription/resourceGroups/$resourcegroup/providers/Microsoft.Storage/storageAccounts/$storageaccountname"
az storage container create -n $storagecontainername --account-name $storageaccountname --public-access off --auth-mode login
az storage share create -n products --quota 10 --account-name $storageaccountname
az storage share create -n dataprotection --quota 10 --account-name $storageaccountname

# Azure SQL Database
az sql server create --subscription $azuresubscription -g $resourcegroup -n $sqlservername -l brazilsouth --admin-user $adminusername --admin-password $sqladminpassword
az sql server firewall-rule create -g $resourcegroup -n "sql-firewall-rule" -s $sqlservername --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az sql db create -g $resourcegroup -n Microsoft.eShopOnWeb.CatalogDb -s $sqlservername -e Basic
az sql db create -g $resourcegroup -n Microsoft.eShopOnWeb.Identity -s $sqlservername -e Basic

# VM Scale Set
az vmss create --subscription $azuresubscription -g $resourcegroup -n $scalesetname --image UbuntuLTS --upgrade-policy-mode automatic --admin-username $adminusername --generate-ssh-keys
## DNS Name
$publicip = az network public-ip list -g $resourcegroup --query "[?contains(name, '$scalesetname')].name" | ConvertFrom-Json
az network public-ip update -g $resourcegroup -n $publicip --dns-name $dnsName


## Application deployment
az vmss extension set -g $resourcegroup -n CustomScript --publisher Microsoft.Azure.Extensions --version 2.0 --vmss-name $scalesetname --settings ".\script-config-$environment.json" --protected-settings ".\protected-config-$environment.json"
## Load Balancer configuration
$loadbalancer = az network lb list -g $resourcegroup --query "[?contains(name, '$scalesetname')].name" | ConvertFrom-Json
az network lb probe create -g $resourcegroup -n healtchecks --lb-name $loadbalancer --protocol http --port 80 --path /health
az network lb rule create -g $resourcegroup -n lbr-web-ch-001 --lb-name $loadbalancer --backend-pool-name "$($scalesetname)LBBEPool" --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --probe-name healthchecks
## Autoscale
az monitor autoscale create -g $resourcegroup -n $autoscalename --resource $scalesetname --resource-type Microsoft.Compute/virtualMachineScaleSets --min-count 2 --max-count 3 --count 2
az monitor autoscale rule create -g $resourcegroup --autoscale-name $autoscalename --condition "Percentage CPU > 70 avg 5m" --scale out 1
az monitor autoscale rule create -g $resourcegroup --autoscale-name $autoscalename --condition "Percentage CPU < 30 avg 5m" --scale in 1
