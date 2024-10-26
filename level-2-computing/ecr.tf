locals {
  ecr = zipmap(var.ecr[*].name, var.ecr)
}

module "ecr" {
  source = "../common/ecr"

  for_each      = local.ecr
  name          = each.value.name
  tag_immutable = each.value.tag_immutable
  kms_enabled   = try(each.value.kms_enabled, null)
  kms_key_alias = try(each.value.kms_key_alias, null)

  tags = merge(local.common_tags, try(each.value.tags, {}))
}