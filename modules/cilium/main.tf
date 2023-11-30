resource "terraform_data" "kube_proxy_disable" {
  count = var.kubeproxy_replace_host != null ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl -n kube-system patch daemonset kube-proxy -p '\"spec\": {\"template\": {\"spec\": {\"nodeSelector\": {\"non-existing\": \"true\"}}}}'"
    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
}

module "cilium" {
  source                 = "littlejo/cilium/helm"
  version                = "0.4.6"
  release_version        = var.release_version
  ebpf_hostrouting       = var.ebpf_hostrouting
  hubble                 = var.hubble
  hubble_ui              = var.hubble_ui
  azure_resource_group   = var.resource_group_name
  kubeproxy_replace_host = var.kubeproxy_replace_host
  gateway_api            = var.gateway_api
  upgrade_compatibility  = var.upgrade_compatibility
  set_values             = var.set_values
  depends_on = [
    terraform_data.kube_proxy_disable,
  ]
}

resource "terraform_data" "wait" {
  provisioner "local-exec" {
    command = "cilium status --wait"
    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
  depends_on = [
    module.cilium
  ]
}
