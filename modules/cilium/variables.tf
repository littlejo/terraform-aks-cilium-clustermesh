variable "kubeconfig" {
  type    = string
  default = ""
}

variable "release_version" {
  type    = string
  default = "1.14.3"
}

variable "ebpf_hostrouting" {
  type    = string
  default = false
}

variable "hubble" {
  type    = string
  default = false
}

variable "hubble_ui" {
  type    = string
  default = false
}

variable "resource_group_name" {
  type = string
}

variable "kubeproxy_replace_host" {
  type    = string
  default = null
}

variable "gateway_api" {
  type    = bool
  default = false
}

variable "upgrade_compatibility" {
  type    = string
  default = null
}

variable "set_values" {
  type    = any
  default = null
}
