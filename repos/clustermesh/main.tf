locals {
  w = terraform.workspace

  files = distinct(concat(tolist(fileset(".", "../kubeconfig/kubeconfig-*")), ["../kubeconfig/${var.aks[local.w].kubeconfig}"]))
}

data "kubernetes_secret" "cilium_ca" {
  count = local.w == "mesh1" ? 0 : 1
  metadata {
    name      = "cilium-ca"
    namespace = "kube-system"
  }

  provider = kubernetes.mesh1
}

data "azurerm_subnet" "this" {
  name                 = var.vnet[local.w].subnet_name
  virtual_network_name = var.vnet[local.w].name
  resource_group_name  = var.resource_group_name
}

module "aks" {
  source = "../../modules/aks"

  name               = var.aks[local.w].name
  kubernetes_version = var.aks[local.w].version
  network_profile    = var.aks[local.w].network_profile
  vnet_subnet_id     = data.azurerm_subnet.this.id

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "local_file" "kubeconfig_aks" {
  content  = module.aks.kubeconfig
  filename = "${path.module}/${var.aks[local.w].kubeconfig}"
}

resource "local_file" "kubeconfig_aks_share" {
  content  = module.aks.kubeconfig
  filename = "../kubeconfig/${var.aks[local.w].kubeconfig}"
}

resource "kubernetes_secret" "cilium_ca" {
  count = local.w == "mesh1" ? 0 : 1
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

module "cilium_mesh" {
  source = "../../modules/cilium"

  kubeconfig = "${path.module}/${var.aks[local.w].kubeconfig}"

  resource_group_name = var.resource_group_name
  set_values          = var.cilium[local.w].set_values

  depends_on = [
    kubernetes_secret.cilium_ca,
  ]

  providers = {
    helm = helm.mesh2
  }
}

module "cilium_enable_mesh" {
  source     = "../../modules/cilium-clustermesh"
  context    = var.aks[local.w].name
  kubeconfig = "${path.module}/${var.aks[local.w].kubeconfig}"

  depends_on = [
    module.cilium_mesh,
  ]
}

resource "terraform_data" "kubeconfig_global_2" {
  provisioner "local-exec" {
    command = "kubectl config view --flatten > ${path.module}/kubeconfig"
    environment = {
      KUBECONFIG = join(":", local.files)
    }
  }

  depends_on = [
    module.cilium_enable_mesh
  ]
}

#resource "terraform_data" "enable_mesh_mesh" {
#  provisioner "local-exec" {
#    command = "cilium clustermesh connect --context ${var.aks.mesh1.name} --destination-context ${var.aks[local.w].name}"
#    environment = {
#      KUBECONFIG = "${path.module}/kubeconfig"
#    }
#  }
#
#  depends_on = [
#    terraform_data.kubeconfig_global_2
#  ]
#}

