variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "name" {
  description = "Name of the cluster AKS"
  type        = string
}

variable "kubernetes_version" {
  description = "version of the cluster AKS"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix of the cluster AKS"
  type        = string
  default     = "cilium"
}

variable "default_node_pool" {
  description = "Feature of default node pool"
  type        = any
  default = {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }
}

variable "network_profile" {
  description = "Feature of network profile"
  type        = any
}

variable "vnet_subnet_id" {
  description = "subnet id of node pool"
  type        = string
}
