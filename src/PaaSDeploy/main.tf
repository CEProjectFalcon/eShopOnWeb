provider "azurerm" {
  features {}
}

variable "location" {
  default = "brazilsouth"
}

variable "keyvault-serviceprincipal" {
  description = "Informe o ID do SP-RBAC para o Azure Key Vault"
}

data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-eshoponweb-cloud"
  location = var.location
}

# Azure App Configuration
resource "azurerm_app_configuration" "appconfig" {
  name                = "appconfig-eshoponweb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "standard"
}

# Azure Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                        = "keyvault-eshoponweb"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = var.keyvault-serviceprincipal

    key_permissions = [
      "create", "decrypt", "delete", "encrypt", "get", "list", "unwrapKey", "wrapKey"
    ]

    secret_permissions = [
      "delete", "get", "list", "set"
    ]
  }
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                     = "creshoponweb"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = true
}

# Log Analytics - Workspace
resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-eshoponweb-aks-cluster"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Free"
}

# Log Analytics - Solution
resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.log.id
  workspace_name        = azurerm_log_analytics_workspace.log.name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }

  depends_on = [
    azurerm_log_analytics_workspace.log
  ]
}

# Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "aks-cluster"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-cluster-eshoponweb"

  default_node_pool {
    name           = "nodeapp"
    node_count     = 2
    enable_auto_scaling	= true
    vm_size        = "Standard_F4s_v2"
  	type           = "VirtualMachineScaleSets"
    min_count 	   = 2
    max_count			 = 5
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
	    log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
    }
  }

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_log_analytics_workspace.log
  ]
}

# AKS - System NodePool
resource "azurerm_kubernetes_cluster_node_pool" "nodesystem" {
  name                  = "nodesystem"  
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-cluster.id
  vm_size               = "Standard_DS2_v2"
  enable_auto_scaling	= false
  node_count            = 2
  mode 					        = "System"

  depends_on = [
    azurerm_kubernetes_cluster.aks-cluster
  ]
}

# Azure Container Registry - Attach AKS
resource "azurerm_role_assignment" "aks-acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks-cluster
  ]
}

# HELM ingress-nginx
resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx/ingress-nginx"
  namespace  = "ingress-controller"

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.nodeSelector.beta.kubernetes.io/os"
    value = "linux"
  }

  set {
    name  = "defaultBackend.nodeSelector.beta.kubernetes.io/os"
    value = "linux"
  }

  set {
    name  = "controller.admissionWebhooks.patch.nodeSelector.beta.kubernetes.io/os"
    value = "linux"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks-cluster
  ]
}