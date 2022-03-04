variable "AKS_RESOURCE_GROUP" {
  default = "MFC-CAC-AKS-DYU"
}
variable "AKS_CLUSTER"{
    default = "AKS-TEST-DYU"
}
data "azurerm_virtual_network" "network"{
  name                = "MFCv2-Internal-CAC-Non-Production-S4"
  resource_group_name = "VNET_MFCv2-Internal-CAC-Non-Production-S4"
}

data "azurerm_subnet" "akssubnet" {
  name = "application"
  virtual_network_name = data.azurerm_virtual_network.network.name
  resource_group_name = data.azurerm_virtual_network.network.resource_group_name
}
resource "azurerm_log_analytics_workspace" "aks" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    
    name                = "akslawdyu"
    location            = "canadacentral"
    resource_group_name = var.AKS_RESOURCE_GROUP
    sku                 = "PerGB2018"#var.log_analytics_workspace_sku
}
resource "azurerm_kubernetes_cluster" "aks" {

  name                = var.AKS_CLUSTER
  location            = "canadacentral"
  resource_group_name = var.AKS_RESOURCE_GROUP
  dns_prefix          = var.AKS_CLUSTER
  public_network_access_enabled = false
  node_resource_group = "AKS_NODE_RG_DYU"

  default_node_pool {
    name                = "systempool"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 3
    vnet_subnet_id      = data.azurerm_subnet.akssubnet.id
    vm_size             = "Standard_DS2_v2"
    availability_zones  = ["1"]
  }

  service_principal {
    client_id = "ed4e731b-970f-4cf0-b0cd-63214b3b784b"
    client_secret = "2mN6bFhCw7433.qx_EgpnZ_-7Gn23CIo~g"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }
    azure_policy {
      enabled = true
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    pod_cidr = "172.29.0.0/16"
    service_cidr = "10.0.0.0/16"
    outbound_type = "userDefinedRouting"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip = "10.0.0.10"
  }

}

