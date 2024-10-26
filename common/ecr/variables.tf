variable "name" {
  type        = string
  description = "Name of the repository"
}

variable "tag_immutable" {
  type        = string
  description = "Whether to enable image tag immutability. Valid values are true of false"
  default     = null
}

variable "kms_enabled" {
  type        = string
  description = "Whether to enable KMS. Valid values are true of false"
  default     = null
}

variable "kms_key_alias" {
  type        = string
  description = "Alias of the customer managed KMS key, in case kms_enabled is true"
  default     = null
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}