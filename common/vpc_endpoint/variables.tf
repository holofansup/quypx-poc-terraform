variable "name" {
  type    = string
  default = null
}

variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "vpc_endpoint_type" {
  type    = string
  default = null
}

variable "ip_address_type" {
  type    = string
  default = null
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

variable "route_table_ids" {
  type    = list(string)
  default = null
}

variable "private_dns_enabled" {
  type    = string
  default = null
}

variable "policy" {
  type    = string
  default = null
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}