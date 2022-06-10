variable "network_cidr" {
  type     = string
  nullable = false
}

variable "project_name" {
  type     = string
  nullable = false
}

variable "template" {
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
