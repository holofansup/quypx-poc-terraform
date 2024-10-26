variable "name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}
