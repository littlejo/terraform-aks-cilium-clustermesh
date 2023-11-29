variable "context" {
  type = string
}

variable "service_type" {
  type    = string
  default = "LoadBalancer"
}

variable "kubeconfig" {
  type    = string
  default = "./kubeconfig"
}
