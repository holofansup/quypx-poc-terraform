locals {
  create_rtb = var.create_rtb == null ? true : var.create_rtb
}

resource "aws_route_table" "this" {
  count = local.create_rtb ? 1 : 0

  vpc_id = var.vpc_id

  tags = merge(
    var.global_resource_tags,
    var.tags,
    {
      Name : var.name
    }
  )
}



locals {
  routes = {
    for route_name, route in var.routes :
    route_name => {
      destination_cidr_block : lookup(route, "destination_cidr_block", null)
      vpc_peering_connection_id : lookup(route, "vpc_peering_connection_id", null)
      gateway_id : lookup(route, "gateway_id", null)
      transit_gateway_id : lookup(route, "transit_gateway_id", null)
      network_interface_id : lookup(route, "network_interface_id", null)
      nat_gateway_id : lookup(route, "nat_gateway_id", null)
    }
    if lookup(route, "create_route", true)
  }
}

resource "aws_route" "this" {
  for_each = local.create_rtb ? local.routes : {}

  route_table_id = aws_route_table.this[0].id

  destination_cidr_block = each.value.destination_cidr_block

  vpc_peering_connection_id = each.value.vpc_peering_connection_id
  gateway_id                = each.value.gateway_id
  transit_gateway_id        = each.value.transit_gateway_id
  network_interface_id      = each.value.network_interface_id
  nat_gateway_id            = each.value.nat_gateway_id
}
