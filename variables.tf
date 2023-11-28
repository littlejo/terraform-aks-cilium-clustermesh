variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "mesh1" {
  description = "Feature of mesh1"
  type        = any
  default = {
    address_space = ["192.168.10.0/24"]
    name          = "clustermesh1"
    subnet_name   = "nodesubnet"
    subnet_cidr   = ["192.168.10.0/24"]
  }
}

variable "mesh2" {
  description = "Feature of mesh2"
  type        = any
  default = {
    address_space = ["192.168.20.0/24"]
    name          = "clustermesh2"
    subnet_name   = "nodesubnet"
    subnet_cidr   = ["192.168.20.0/24"]
  }
}

variable "aks_mesh1" {
  description = "Feature of aks for the mesh1"
  type        = any
  default = {
    name    = "cilium-clustermesh1"
    version = "1.27"
    network_profile = {
      service_cidr   = "10.11.0.0/16"
      dns_service_ip = "10.11.0.10"
    }
    kubeconfig = "kubeconfig-cluster1"
  }
}

variable "aks_mesh2" {
  description = "Feature of aks for the mesh2"
  type        = any
  default = {
    name    = "cilium-clustermesh2"
    version = "1.27"
    network_profile = {
      service_cidr   = "10.21.0.0/16"
      dns_service_ip = "10.21.0.10"
    }
    kubeconfig = "kubeconfig-cluster2"
  }
}

variable "cilium_1" {
  description = "Feature of cilium"
  type = object({
    type                   = string
    version                = optional(string, "1.14.3")
    kube-proxy-replacement = optional(bool, false)
    ebpf-hostrouting       = optional(bool, false)
    hubble                 = optional(bool, false)
    hubble-ui              = optional(bool, false)
    gateway-api            = optional(bool, false)
    preflight-version      = optional(string, null)
    upgrade-compatibility  = optional(string, null)
    set_values             = optional(list(object({ name = string, value = string })))
  })
  default = {
    type                   = "cilium_custom" #other option: byocni
    version                = "1.14.3"
    kube-proxy-replacement = true
    ebpf-hostrouting       = true
    hubble                 = true
    set_values             = [{ name = "cluster.id", value = "1" }, { name = "cluster.name", value = "cilium-clustermesh1" }, { name = "ipam.operator.clusterPoolIPv4PodCIDRList", value = "{10.10.0.0/16}" }]
  }
}

variable "cilium_2" {
  description = "Feature of cilium"
  type = object({
    type                   = string
    version                = optional(string, "1.14.3")
    kube-proxy-replacement = optional(bool, false)
    ebpf-hostrouting       = optional(bool, false)
    hubble                 = optional(bool, false)
    hubble-ui              = optional(bool, false)
    gateway-api            = optional(bool, false)
    preflight-version      = optional(string, null)
    upgrade-compatibility  = optional(string, null)
    set_values             = optional(list(object({ name = string, value = string })))
  })
  default = {
    type                   = "cilium_custom" #other option: byocni
    version                = "1.14.3"
    kube-proxy-replacement = true
    ebpf-hostrouting       = true
    hubble                 = true
    set_values             = [{ name = "cluster.id", value = "2" }, { name = "cluster.name", value = "cilium-clustermesh2" }, { name = "ipam.operator.clusterPoolIPv4PodCIDRList", value = "{10.20.0.0/16}" }]
  }
}
