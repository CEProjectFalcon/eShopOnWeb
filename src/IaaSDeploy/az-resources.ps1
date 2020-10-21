az login

# Resource Group
az group create -l brazilsouth -n rg-eshoponweb

# VNet
az network vnet create -g rg-eshoponweb -l brazilsouth -n vnet-ch-001 --address-prefixes 10.1.0.0/16 --subnet-name snet-web-ch-001 --subnet-prefixes 10.1.0.0/24
az network nsg create -g rg-eshoponweb -n nsg-weballow-ch-001
az network nsg rule create -g rg-eshoponweb --nsg-name nsg-weballow-ch-001 -n nsgr-http-ch-001 --protocol '*' --direction inbound --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 80 443 --access allow --priority 200

# Deployment storage
az storage account create -g rg-eshoponweb -n stdeploych001 -l brazilsouth --sku Standard_LRS --encryption-services blob
az ad signed-in-user show --query objectId -o tsv | az role assignment create --role "Storage Blob Data Contributor" --assignee ateoi@microsoft.com --scope "/subscriptions/fcb2616f-096b-4e78-b6ee-72db022919b0/resourceGroups/rg-eshoponweb/providers/Microsoft.Storage/storageAccounts/stdeploych001"
az storage container create -n stcdeploych001 --account-name stdeploych001 --public-access off --auth-mode login
az storage account keys list -g rg-eshoponweb -n stdeploych001

# Azure SQL Database
az sql server create -g rg-eshoponweb -n sql-eshoponweb-ch-001 -l brazilsouth --admin-user eshopadmin --admin-password s3nh@Comple*4
az sql server firewall-rule create -g rg-eshoponweb -n sqlfw-allowazureips-ch-001 -s sql-eshoponweb-ch-001 --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az sql db create -g rg-eshoponweb -n Microsoft.eShopOnWeb.CatalogDb -s sql-eshoponweb-ch-001 -e Basic
az sql db create -g rg-eshoponweb -n Microsoft.eShopOnWeb.Identity -s sql-eshoponweb-ch-001 -e Basic

# VM Scale Set
az vmss create -g rg-eshoponweb -n vmss-web-ch-001 --image UbuntuLTS --upgrade-policy-mode automatic --admin-username eshopadmin --generate-ssh-keys
## DNS Name
az network public-ip list -g rg-eshoponweb --query "[?contains(name, 'vmss-web-ch-001')].name"
az network public-ip update -g rg-eshoponweb -n vmss-web-ch-001LBPublicIP --dns-name eshoponwebch001
## Application deployment
az vmss extension set -g rg-eshoponweb -n CustomScript --publisher Microsoft.Azure.Extensions --version 2.0 --vmss-name vmss-web-ch-001 --settings .\script.config.json --protected-settings .\protected-config.json
## Load Balancer configuration
az network lb list -g rg-eshoponweb --query "[?contains(name, 'vmss-web-ch-001')].name"
az network lb probe create -g rg-eshoponweb -n healtchecks --lb-name vmss-web-ch-001LB --protocol http --port 80 --path /health
az network lb rule create -g rg-eshoponweb -n lbr-web-ch-001 --lb-name vmss-web-ch-001LB --backend-pool-name vmss-web-ch-001LBBEPool --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --probe-name healthchecks --load-distribution SourceIP
## Autoscale
az monitor autoscale create -g rg-eshoponweb -n vmssas-web-ch-001 --resource vmss-web-ch-001 --resource-type Microsoft.Compute/virtualMachineScaleSets --min-count 2 --max-count 3 --count 2
az monitor autoscale rule create -g rg-eshoponweb --autoscale-name vmssas-web-ch-001 --condition "Percentage CPU > 70 avg 5m" --scale out 1
az monitor autoscale rule create -g rg-eshoponweb --autoscale-name vmssas-web-ch-001 --condition "Percentage CPU < 30 avg 5m" --scale in 1
