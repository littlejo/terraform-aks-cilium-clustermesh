resource "azurerm_kubernetes_cluster" "this" {
  name               = var.name
  kubernetes_version = var.kubernetes_version

  azure_policy_enabled = true

  dns_prefix = var.dns_prefix


  default_node_pool {
    name           = var.default_node_pool.name
    node_count     = var.default_node_pool.node_count
    vm_size        = var.default_node_pool.vm_size
    vnet_subnet_id = var.vnet_subnet_id
  }

  network_profile {
    network_plugin = "none"

    dns_service_ip = var.network_profile.dns_service_ip
    service_cidr   = var.network_profile.service_cidr
  }

  identity {
    type = "SystemAssigned"
  }

  location            = var.location
  resource_group_name = var.resource_group_name
}
