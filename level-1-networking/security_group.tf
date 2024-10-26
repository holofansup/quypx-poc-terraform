module "security_group" {
  source = "../common/security_group"

  vpc_id  = lookup(module.vpc, var.security_groups.vpc, null).id
  sg_list = var.security_groups.sg_list

  global_resource_tags = var.common_tags
}
