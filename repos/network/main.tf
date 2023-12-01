locals {
  #kubeproxy_replace_host = var.cilium.kube-proxy-replacement ? split("https://", azurerm_kubernetes_cluster.this.kube_config[0].host)[1] : null
}

module "vnet" {
  source = "../../modules/network"

  for_each      = var.vnet
  address_space = each.value.address_space
  name          = each.value.name
  subnet_name   = each.value.subnet_name
  subnet_cidr   = each.value.subnet_cidr

  location            = var.location
  resource_group_name = var.resource_group_name
}

module "peering" {
  count               = var.vnet_share == "peering" ? 1 : 0
  source              = "../../modules/peering"
  vnet_1              = { id = module.vnet["mesh1"].id, name = var.vnet.mesh1.name }
  vnet_2              = { id = module.vnet["mesh2"].id, name = var.vnet.mesh2.name }
  resource_group_name = var.resource_group_name
}

module "virtual_wan" {
  count  = var.vnet_share == "virtual_wan" ? 1 : 0
  source = "../../modules/virtual-wan"

  address_prefix = "10.0.0.0/16"

  vnet_ids = {
    mesh1 = module.vnet["mesh1"].id
    mesh2 = module.vnet["mesh2"].id
    mesh3 = module.vnet["mesh3"].id
  }

  resource_group_name = var.resource_group_name
  location            = var.location
}
