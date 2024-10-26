locals {
  vpc_endpoints = zipmap(var.vpc_endpoints[*].name, var.vpc_endpoints)
}

module "vpc_endpoint" {
  source = "../common/vpc_endpoint"

  for_each = local.vpc_endpoints

  name = each.value.name

  vpc_id            = lookup(module.vpc, each.value.vpc, null).id
  service_name      = each.value.service
  vpc_endpoint_type = each.value.type
  ip_address_type   = lookup(each.value, "ip_address_type", null)

  subnet_ids = [
    for subnet in lookup(each.value, "subnets", []) :
    lookup(module.subnet, subnet, null).id if
    lookup(module.subnet, subnet, null) != null
  ]
  security_group_ids = [
    for security_group in lookup(each.value, "security_groups", []) :
    lookup(module.security_group.ids, security_group, null) if
    lookup(module.security_group.ids, security_group, null) != null
  ]
  route_table_ids = [
    for route_table in lookup(each.value, "route_tables", []) :
    lookup(module.route_table, route_table, null).id if
    lookup(module.route_table, route_table, null) != null
  ]

  private_dns_enabled = lookup(each.value, "private_dns_enabled", null)
  policy              = lookup(each.value, "policy", null)

  global_resource_tags = var.common_tags
  tags                 = lookup(each.value, "tags", null)
}