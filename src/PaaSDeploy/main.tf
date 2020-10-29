provider "azurerm" {
  features {}
}

variable "location" {
  description = "brasilsouth"
}

resource "azurerm_resource_group" "rg-eshoponweb-cloud" {
  name     = "rg-eshoponweb-cloud"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "log-eshoponweb-aks-cluster" {
  name                = "log-eshoponweb-aks-cluster"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-eshoponweb-cloud.name
  sku                 = "Free"
}

resource "azurerm_log_analytics_solution" "Containers" {
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.log-eshoponweb-aks-cluster.id
  workspace_name        = azurerm_log_analytics_workspace.log-eshoponweb-aks-cluster.name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-eshoponweb-cloud.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_container_registry" "creshoponweb" {
  name                     = "creshoponweb"
  resource_group_name      = azurerm_resource_group.rg-eshoponweb-cloud.name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = false
}

#Vincular ACR ao AKS

#Verificar HELM do Nginx

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "aks-cluster"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-eshoponweb-cloud.name
  dns_prefix          = "aks-cluster-eshoponweb"

  default_node_pool {
    name           = "nodesystem"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
	type           = "VirtualMachineScaleSets"
	mode		   = "System"
  }
  
  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "standard"
    outbound_type = "loadBalancer"
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled = true
	  log_analytics_workspace_id = azurerm_log_analytics_workspace.log-eshoponweb-aks-cluster.id
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "nodeapp" {
  name                  = "nodeapp"  
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-cluster.id
  vm_size               = "Standard_F4s_v2"
  enable_auto_scaling	= true
  node_count            = 2
  min_count 			= 2
  max_count				= 5
  mode 					= "User"
}
