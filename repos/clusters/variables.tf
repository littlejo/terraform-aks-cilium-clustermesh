variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "vnet" {
  description = "Feature of vnet"
  type        = any
  default = {
    mesh1 = {
      address_space = ["192.168.10.0/24"]
      name          = "clustermesh1"
      subnet_name   = "nodesubnet"
      subnet_cidr   = ["192.168.10.0/24"]
    }
    mesh2 = {
      address_space = ["192.168.20.0/24"]
      name          = "clustermesh2"
      subnet_name   = "nodesubnet"
      subnet_cidr   = ["192.168.20.0/24"]
    }
    mesh3 = {
      address_space = ["192.168.30.0/24"]
      name          = "clustermesh3"
      subnet_name   = "nodesubnet"
      subnet_cidr   = ["192.168.30.0/24"]
    }
  }
}

variable "aks" {
  description = "Feature of aks"
  type        = any
  default = {
    mesh1 = {
      name    = "cilium-clustermesh1"
      version = "1.27"
      network_profile = {
        service_cidr   = "10.11.0.0/16"
        dns_service_ip = "10.11.0.10"
      }
      kubeconfig = "kubeconfig-cluster1"
    }
    mesh2 = {
      name    = "cilium-clustermesh2"
      version = "1.27"
      network_profile = {
        service_cidr   = "10.21.0.0/16"
        dns_service_ip = "10.21.0.10"
      }
      kubeconfig = "kubeconfig-cluster2"
    }
    mesh3 = {
      name    = "cilium-clustermesh3"
      version = "1.27"
      network_profile = {
        service_cidr   = "10.31.0.0/16"
        dns_service_ip = "10.31.0.10"
      }
      kubeconfig = "kubeconfig-cluster3"
    }
  }
}

variable "cilium" {
  description = "Feature of cilium"
  type = map(object({
    type                   = string
    version                = optional(string, "1.14.3")
    kube-proxy-replacement = optional(bool, false)
    ebpf-hostrouting       = optional(bool, false)
    hubble                 = optional(bool, false)
    hubble-ui              = optional(bool, false)
    gateway-api            = optional(bool, false)
    shared_ca              = optional(bool, true)
    preflight-version      = optional(string, null)
    upgrade-compatibility  = optional(string, null)
    set_values             = optional(list(object({ name = string, value = string })))
  }))
  default = {
    mesh1 = {
      type                   = "cilium_custom" #other option: byocni
      version                = "1.14.3"
      kube-proxy-replacement = true
      ebpf-hostrouting       = true
      hubble                 = true
      shared_ca              = false
      set_values = [
        { name = "cluster.id", value = "1" },
        { name = "cluster.name", value = "cilium-clustermesh1" },
        { name = "ipam.operator.clusterPoolIPv4PodCIDRList", value = "{10.10.0.0/16}" },
      ]
    }
    mesh2 = {
      type                   = "cilium_custom" #other option: byocni
      version                = "1.14.3"
      kube-proxy-replacement = true
      ebpf-hostrouting       = true
      hubble                 = true
      set_values = [
        { name = "cluster.id", value = "2" },
        { name = "cluster.name", value = "cilium-clustermesh2" },
        { name = "ipam.operator.clusterPoolIPv4PodCIDRList", value = "{10.20.0.0/16}" }
      ]
    }
    mesh3 = {
      type                   = "cilium_custom" #other option: byocni
      version                = "1.14.3"
      kube-proxy-replacement = true
      ebpf-hostrouting       = true
      hubble                 = true
      set_values = [
        { name = "cluster.id", value = "3" },
        { name = "cluster.name", value = "cilium-clustermesh3" },
        { name = "ipam.operator.clusterPoolIPv4PodCIDRList", value = "{10.30.0.0/16}" }
      ]
    }
  }
}
