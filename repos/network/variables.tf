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

variable "vnet_share" {
  type    = string
  default = "virtual_wan"
}
