variable "vpc_id" {
  type = string
}

variable "sg_list" {
  type    = any
  default = []
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}
