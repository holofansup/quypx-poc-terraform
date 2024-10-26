resource "aws_iam_policy" "iam_policy" {
  name        = var.name
  path        = var.path
  description = try(var.description, "Managed By Terraform")

  policy = var.policy

  tags = merge(try(var.global_resource_tags, null), try(var.tags, null))
}
