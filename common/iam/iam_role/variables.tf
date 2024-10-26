variable "create_instance_profile" {
  description = "Whether to create an instance profile"
  type        = bool
  default     = false
}

variable "role_name" {
  description = "IAM role name"
  type        = string
}

variable "role_name_prefix" {
  description = "IAM role name prefix"
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "role_trust_policy" {
  description = "Policy that grants an entity permission to assume the role, essentially the trust policy"
  type        = string
}

variable "description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = 3600
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "aws_managed_policy_names" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role."
  type        = list(string)
  default     = null
}

variable "custom_policy_arns" {
  description = "The ARN of the IAM policy that is to be created with IAM_Policy module and attach to the IAM role."
  type        = list(string)
  default     = null
}

variable "global_resource_tags" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = null
}