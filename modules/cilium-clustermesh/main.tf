resource "terraform_data" "enable_clustermesh" {
  provisioner "local-exec" {
    command = "cilium clustermesh enable --service-type ${var.service_type} --context ${var.context}"
    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
}
