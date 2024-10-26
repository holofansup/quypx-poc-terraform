variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "enable_dns_hostname" {
  type = bool
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}