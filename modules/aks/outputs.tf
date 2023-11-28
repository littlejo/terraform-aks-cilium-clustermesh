output "kubeconfig" {
  value = azurerm_kubernetes_cluster.this.kube_config_raw
}

output "host" {
  value = azurerm_kubernetes_cluster.this.kube_config[0].host
}

output "client_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
}

output "client_key" {
  value = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
}

output "cluster_ca_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}
