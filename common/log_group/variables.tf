variable "log_group_name" {
  type = string
}

variable "retention_in_days" {
  type = number
}
variable "kms_key_id" {
  type    = string
  default = null
}

variable "global_resource_tags" {
  type    = map(string)
  default = null
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "policy_attached" {
  type    = bool
  default = null
}

variable "iam_policy_document_json" {
  type    = string
  default = null
}

variable "log_group_policy_name" {
  type    = string
  default = null
}

variable "log_subscription_filter_enabled" {
  type    = bool
  default = false
}

variable "log_subscription_filter_name" {
  type    = string
  default = null
}

variable "log_destination_arn" {
  type    = string
  default = null
}

variable "log_filter_pattern" {
  type    = string
  default = null
}

variable "kinesis_iam_role_arn" {
  type    = string
  default = null
}

variable "distribution_method_to_destination" {
  type    = string
  default = null
}