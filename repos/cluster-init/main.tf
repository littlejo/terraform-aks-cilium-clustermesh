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

#module "peering" {
#  source = "../../modules/peering"
#  vnet_1 = { id = module.vnet["mesh1"].id, name = var.vnet.mesh1.name }
#  vnet_2 = { id = module.vnet["mesh2"].id, name = var.vnet.mesh2.name }
#  resource_group_name = var.resource_group_name
#}

module "virtual_wan" {
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

module "aks" {
  source = "../../modules/aks"

  name               = var.aks.mesh1.name
  kubernetes_version = var.aks.mesh1.version
  network_profile    = var.aks.mesh1.network_profile
  vnet_subnet_id     = module.vnet["mesh1"].subnet_id

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "local_file" "kubeconfig_aks" {
  content  = module.aks.kubeconfig
  filename = "${path.module}/${var.aks.mesh1.kubeconfig}"
}

resource "local_file" "kubeconfig_aks_share" {
  content  = module.aks.kubeconfig
  filename = "../kubeconfig/${var.aks.mesh1.kubeconfig}"
}

module "cilium_mesh1" {
  source = "../../modules/cilium"

  kubeconfig = "${path.module}/${var.aks.mesh1.kubeconfig}"

  resource_group_name = var.resource_group_name
  set_values          = var.cilium.mesh1.set_values

  depends_on = [
    local_file.kubeconfig_aks,
  ]

  providers = {
    helm = helm.mesh1
  }
}

module "cilium_enable_mesh1" {
  source     = "../../modules/cilium-clustermesh"
  context    = var.aks.mesh1.name
  kubeconfig = "${path.module}/${var.aks.mesh1.kubeconfig}"

  depends_on = [
    module.cilium_mesh1,
  ]
}
