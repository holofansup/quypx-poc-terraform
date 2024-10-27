locals {
  subnets      = zipmap(var.subnets[*].name, var.subnets)
  route_tables = zipmap(var.route_tables[*].name, var.route_tables)
}

module "subnet" {
  source = "../common/subnet"

  for_each = local.subnets

  create_subnet = lookup(each.value, "create_subnet", null)

  vpc_id               = lookup(module.vpc, each.value.vpc, null).id
  name                 = each.value.name
  cidr_block           = each.value.cidr_block
  availablility_zone   = each.value.availablility_zone
  global_resource_tags = var.common_tags
  tags                 = each.value.tags
}

module "route_table" {
  source = "../common/route_table"

  for_each = local.route_tables

  create_rtb = lookup(each.value, "create_rtb", null)

  vpc_id = lookup(module.vpc, each.value.vpc, null).id
  name   = each.value.name

  # subnet_ids = [
  #   for subnet in lookup(each.value, "subnets", []) :
  #   lookup(module.subnet, subnet).id
  #   if lookup(module.subnet, subnet, null) != null
  # ]

  routes = {
    for route_name, route in lookup(each.value, "routes", {}) :
    route_name => {
      destination_cidr_block : lookup(route, "destination_cidr_block", null)
      gateway_id : try(lookup(aws_internet_gateway.this, lookup(route, "internet_gateway")).id, null)
      nat_gateway_id : try(lookup(module.nat_gateway, lookup(route, "nat_gateway")).id, null)
    }
  }
  global_resource_tags = var.common_tags
  tags                 = each.value.tags

  depends_on = [module.nat_gateway, module.subnet]
}

locals {
  route_table_associations = flatten([
    for rtb in local.route_tables :
    [
      for subnet in lookup(rtb, "subnets", []) : {
        subnet         = subnet
        route_table_id = rtb.name
      }
    ]
  ])
}

resource "aws_route_table_association" "this" {
  for_each = zipmap(local.route_table_associations[*].subnet, local.route_table_associations)

  subnet_id      = lookup(module.subnet, each.value.subnet).id
  route_table_id = lookup(module.route_table, each.value.route_table_id).id
}
