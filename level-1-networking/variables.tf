variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "vpc" {
  type = list(any)
}

variable "nat_gateway" {
  type = list(any)
}

variable "subnets" {
  type = list(any)
}

variable "security_groups" {
  type = any
}

variable "route_tables" {
  type = list(any)
}

variable "vpc_endpoints" {
  type = any
}