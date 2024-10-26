locals {
  image_tag_mutability = try(tobool(lower(var.tag_immutable)), false) == true ? "IMMUTABLE" : "MUTABLE"
  encryption_type      = var.kms_enabled == true ? "KMS" : "AES256"
  kms_key_alias        = var.kms_key_alias != null && var.kms_key_alias != "" ? format("alias/%s", var.kms_key_alias) : null
}

data "aws_kms_key" "by_alias" {
  count = local.kms_key_alias != null ? 1 : 0

  key_id = local.kms_key_alias
}

resource "aws_ecr_repository" "this" {
  name = var.name

  image_tag_mutability = local.image_tag_mutability

  encryption_configuration {
    encryption_type = local.encryption_type
    kms_key         = try(data.aws_kms_key.by_alias[0].arn, null)
  }

  tags = merge(var.global_resource_tags, var.tags)
}
