variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type    = string
  default = "virtual-wan"
}

variable "hub_name" {
  type    = string
  default = "hub"
}

variable "address_prefix" {
  type = string
}

variable "vnet_ids" {
  type = map(string)
}
