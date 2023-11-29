resource "terraform_data" "wait" {
  provisioner "local-exec" {
    command = "cilium status --context ${var.context} --wait"
    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }
}

resource "terraform_data" "enable_clustermesh" {
  provisioner "local-exec" {
    command = "cilium clustermesh enable --service-type ${var.service_type} --context ${var.context}"
    environment = {
      KUBECONFIG = var.kubeconfig
    }
  }

  depends_on = [
    terraform_data.wait,
  ]
}
