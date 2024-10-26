variable "create_subnet" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "availablility_zone" {
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