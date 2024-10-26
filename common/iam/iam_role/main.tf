data "aws_iam_policy" "aws_managed_policy" {
  count = length(compact(var.aws_managed_policy_names))

  name = var.aws_managed_policy_names[count.index]
}

locals {
  role_policy_arns = flatten([
    compact(var.custom_policy_arns),
    data.aws_iam_policy.aws_managed_policy[*].arn,
  ])
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  name_prefix          = var.role_name_prefix
  path                 = var.role_path
  max_session_duration = var.max_session_duration
  description          = var.description

  force_detach_policies = var.force_detach_policies
  permissions_boundary  = var.role_permissions_boundary_arn
  managed_policy_arns   = local.role_policy_arns

  assume_role_policy = var.role_trust_policy
  tags               = merge(var.global_resource_tags, var.tags)
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.role_name
  path = var.role_path
  role = aws_iam_role.this.name

  tags = merge(var.global_resource_tags, var.tags)
}