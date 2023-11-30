locals {
  #kubeproxy_replace_host = var.cilium.kube-proxy-replacement ? split("https://", azurerm_kubernetes_cluster.this.kube_config[0].host)[1] : null
}

module "vnet" {
  source = "./modules/network"

  for_each      = var.vnet
  address_space = each.value.address_space
  name          = each.value.name
  subnet_name   = each.value.subnet_name
  subnet_cidr   = each.value.subnet_cidr

  location            = var.location
  resource_group_name = var.resource_group_name
}

module "peering" {
  source = "./modules/peering"
  vnet_1 = { id = module.vnet["mesh1"].id, name = var.vnet.mesh1.name }
  vnet_2 = { id = module.vnet["mesh2"].id, name = var.vnet.mesh2.name }

  resource_group_name = var.resource_group_name
}

module "aks" {
  source = "./modules/aks"

  for_each           = var.aks
  name               = each.value.name
  kubernetes_version = each.value.version
  network_profile    = each.value.network_profile
  vnet_subnet_id     = module.vnet[each.key].subnet_id

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "local_file" "kubeconfig_aks_1" {
  content  = module.aks["mesh1"].kubeconfig
  filename = "${path.module}/${var.aks.mesh1.kubeconfig}"
}

resource "local_file" "kubeconfig_aks_2" {
  content  = module.aks["mesh2"].kubeconfig
  filename = "${path.module}/${var.aks.mesh2.kubeconfig}"
}

resource "terraform_data" "kubeconfig_global" {
  provisioner "local-exec" {
    command = "kubectl config view --flatten > ${path.module}/kubeconfig"
    environment = {
      KUBECONFIG = "${path.module}/${var.aks.mesh1.kubeconfig}:${path.module}/${var.aks.mesh2.kubeconfig}"
    }
  }

  depends_on = [
    local_file.kubeconfig_aks_1,
    local_file.kubeconfig_aks_2,
  ]
}

module "cilium_mesh1" {
  count  = var.cilium.mesh1.type == "cilium_custom" ? 1 : 0
  source = "./modules/cilium"

  kubeconfig = "${path.module}/${var.aks.mesh1.kubeconfig}"

  resource_group_name = var.resource_group_name
  set_values          = var.cilium.mesh1.set_values

  depends_on = [
    local_file.kubeconfig_aks_1,
    local_file.kubeconfig_aks_2,
  ]

  providers = {
    helm = helm.mesh1
  }
}

data "kubernetes_secret" "cilium_ca" {
  count = var.cilium.mesh1.type == "cilium_custom" ? 1 : 0
  metadata {
    name      = "cilium-ca"
    namespace = "kube-system"
  }

  depends_on = [
    module.cilium_mesh1
  ]

  provider = kubernetes.mesh1
}


resource "kubernetes_secret" "cilium_ca" {
  count = var.cilium.mesh1.shared_ca && var.cilium.mesh1.type == "cilium_custom" ? 1 : 0
  metadata {
    name        = "cilium-ca"
    namespace   = "kube-system"
    annotations = data.kubernetes_secret.cilium_ca[0].metadata[0].annotations
    labels      = data.kubernetes_secret.cilium_ca[0].metadata[0].labels
  }

  data = data.kubernetes_secret.cilium_ca[0].data

  type     = data.kubernetes_secret.cilium_ca[0].type
  provider = kubernetes.mesh2
}

module "cilium_mesh2" {
  count  = var.cilium.mesh2.type == "cilium_custom" ? 1 : 0
  source = "./modules/cilium"

  kubeconfig = "${path.module}/${var.aks.mesh2.kubeconfig}"

  resource_group_name = var.resource_group_name
  set_values          = var.cilium.mesh2.set_values

  depends_on = [
    kubernetes_secret.cilium_ca,
  ]

  providers = {
    helm = helm.mesh2
  }
}

module "cilium_enable_mesh1" {
  count   = var.cilium.mesh1.type == "cilium_custom" ? 1 : 0
  source  = "./modules/cilium-clustermesh"
  context = var.aks.mesh1.name

  depends_on = [
    module.cilium_mesh1,
  ]
}

module "cilium_enable_mesh2" {
  count      = var.cilium.mesh2.type == "cilium_custom" ? 1 : 0
  source     = "./modules/cilium-clustermesh"
  context    = var.aks.mesh2.name
  kubeconfig = "${path.module}/kubeconfig"

  depends_on = [
    module.cilium_mesh2,
  ]
}

resource "terraform_data" "enable_mesh1_mesh2" {
  count = var.cilium.mesh1.type == "cilium_custom" && var.cilium.mesh2.type == "cilium_custom" ? 1 : 0
  provisioner "local-exec" {
    command = "cilium clustermesh connect --context ${var.aks.mesh1.name} --destination-context ${var.aks.mesh2.name}"
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig"
    }
  }

  depends_on = [
    module.cilium_enable_mesh1,
    module.cilium_enable_mesh2,
  ]
}


#output "toto" {
#  value = data.kubernetes_resource.example
#}
