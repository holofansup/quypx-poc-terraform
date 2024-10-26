variable "create_rtb" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

# variable "subnet_ids" {
#   type    = list(string)
#   default = []
# }

variable "routes" {
  type = map(any)
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}