variable "name" {
  description = "The name of the policy"
  type        = string
}

variable "description" {
  description = "The description of the policy"
  type        = string
  default     = null
}

variable "path" {
  description = "Path in which to create the policy"
  type        = string
  default     = null
}

variable "policy" {
  description = "The JSON formatted policy document"
  type        = string
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(any)
  default     = {}
}
