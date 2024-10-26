locals {
  ip_address_type_list = ["ipv4", "ipv6", "dualstack"]
  ip_address_type      = var.vpc_endpoint_type != "Gateway" ? try(local.ip_address_type_list[index(local.ip_address_type_list, lower(var.ip_address_type))], "ipv4") : null

  private_dns_enabled_list = ["true", "false"]
  private_dns_enabled      = try(contains(local.private_dns_enabled_list, lower(var.private_dns_enabled)), false)
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = var.vpc_endpoint_type

  ip_address_type    = local.ip_address_type
  subnet_ids         = var.subnet_ids != null ? var.subnet_ids : []
  security_group_ids = var.security_group_ids != null ? var.security_group_ids : []
  route_table_ids    = var.route_table_ids != null ? var.route_table_ids : []

  private_dns_enabled = local.private_dns_enabled
  policy              = var.policy

  tags = merge(
    var.global_resource_tags,
    var.tags,
    {
      Name : var.name
    }
  )
}
