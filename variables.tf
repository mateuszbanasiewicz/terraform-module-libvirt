variable "network_cidr" {
  type     = string
  nullable = false
}

variable "project_name" {
  type     = string
  nullable = false
}

variable "base_image" {
  type   = string
  nullable = false
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
