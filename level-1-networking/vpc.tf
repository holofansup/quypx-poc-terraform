locals {
  vpc = zipmap(var.vpc[*].name, var.vpc)
  igw = zipmap(var.vpc[*].internet_gateway_name, var.vpc)
  nat = zipmap(var.nat_gateway[*].name, var.nat_gateway)
}

module "vpc" {
  source = "../common/vpc"

  for_each = local.vpc

  name                = each.value.name
  cidr_block          = each.value.cidr_block
  enable_dns_hostname = each.value.enable_dns_hostname

  global_resource_tags = var.common_tags
  tags                 = each.value.tags
}

resource "aws_internet_gateway" "this" {
  for_each = local.igw

  vpc_id = lookup(module.vpc, each.value.name).id

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name : each.value.internet_gateway_name
    }
  )
}

module "nat_gateway" {
  source = "../common/nat_gateway"

  for_each = local.nat

  name      = each.value.name
  subnet_id = lookup(module.subnet, each.value.subnet, null).id

  global_resource_tags = var.common_tags
  tags                 = lookup(each.value, "tags", null)

  depends_on = [aws_internet_gateway.this]
}
