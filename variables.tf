variable "network_cidr" {
  type     = string
  nullable = false
}

variable "project_id" {
  type     = string
  nullable = false
}

variable "base_image" {
  type   = string
  default  = null
  nullable = true
}

variable "vms" {
  type   = map
  nullable = false
}

variable "domain" {
  type = string
  nullable = false
}

variable "ansible_variables" {
  type = map
  nullable = false
}

variable "network_mask" {
  type     = string
  nullable = false
}

variable "network_gateway" {
  type     = string
  nullable = false
}

variable "dns_records" {
  type     = map
  nullable = false
}
