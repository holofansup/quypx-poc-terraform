locals {
  create_subnet = var.create_subnet == null ? true : var.create_subnet
}

resource "aws_subnet" "this" {
  count = local.create_subnet ? 1 : 0

  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availablility_zone

  tags = merge(
    var.global_resource_tags,
    var.tags,
    {
      Name : var.name
    }
  )
}
