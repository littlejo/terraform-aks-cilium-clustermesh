variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "address_space" {
  description = "list of CIDRs vnet"
  type        = list(string)
}

variable "name" {
  description = "Name of vnet"
  type        = string
}

variable "subnet_name" {
  description = "Name of subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "list of CIDRs subnet"
  type        = list(string)
}
