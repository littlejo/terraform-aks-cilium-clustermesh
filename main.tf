locals {
  #kubeproxy_replace_host = var.cilium.kube-proxy-replacement ? split("https://", azurerm_kubernetes_cluster.this.kube_config[0].host)[1] : null
}

module "vnet_1" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.mesh1.address_space
  name                = var.mesh1.name
  subnet_name         = var.mesh1.subnet_name
  subnet_cidr         = var.mesh1.subnet_cidr
}

module "vnet_2" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.mesh2.address_space
  name                = var.mesh2.name
  subnet_name         = var.mesh2.subnet_name
  subnet_cidr         = var.mesh2.subnet_cidr
}

module "peering" {
  source              = "./modules/peering"
  vnet_1              = { id = module.vnet_1.id, name = var.mesh1.name }
  vnet_2              = { id = module.vnet_2.id, name = var.mesh2.name }
  resource_group_name = var.resource_group_name
}

module "cluster_1" {
  source              = "./modules/aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.aks_mesh1.name
  kubernetes_version  = var.aks_mesh1.version
  network_profile     = var.aks_mesh1.network_profile
  vnet_subnet_id      = module.vnet_1.subnet_id
}


module "cluster_2" {
  source              = "./modules/aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.aks_mesh2.name
  kubernetes_version  = var.aks_mesh2.version
  network_profile     = var.aks_mesh2.network_profile
  vnet_subnet_id      = module.vnet_2.subnet_id
}

resource "local_file" "kubeconfig_cluster_1" {
  content  = module.cluster_1.kubeconfig
  filename = "${path.module}/${var.aks_mesh1.kubeconfig}"
}

resource "local_file" "kubeconfig_cluster_2" {
  content  = module.cluster_2.kubeconfig
  filename = "${path.module}/${var.aks_mesh2.kubeconfig}"
}

resource "terraform_data" "kubeconfig_global" {
  provisioner "local-exec" {
    command = "kubectl config view --flatten > ${path.module}/kubeconfig"
    environment = {
      KUBECONFIG = "${path.module}/${var.aks_mesh1.kubeconfig}:${path.module}/${var.aks_mesh2.kubeconfig}"
    }
  }

  depends_on = [
    local_file.kubeconfig_cluster_1,
    local_file.kubeconfig_cluster_2,
  ]
}

module "cilium_1" {
  count  = var.cilium_1.type == "cilium_custom" ? 1 : 0
  source = "./modules/cilium"

  kubeconfig = "${path.module}/${var.aks_mesh1.kubeconfig}"

  resource_group_name = var.resource_group_name
  set_values          = var.cilium_1.set_values

  depends_on = [
    local_file.kubeconfig_cluster_1,
    local_file.kubeconfig_cluster_2,
  ]

  providers = {
    helm = helm.mesh1
  }
}

module "cilium_2" {
  count  = var.cilium_1.type == "cilium_custom" ? 1 : 0
  source = "./modules/cilium"

  kubeconfig = "${path.module}/${var.aks_mesh2.kubeconfig}"

  resource_group_name = var.resource_group_name
  set_values          = var.cilium_2.set_values

  depends_on = [
    local_file.kubeconfig_cluster_1,
    local_file.kubeconfig_cluster_2,
  ]

  providers = {
    helm = helm.mesh2
  }
}

