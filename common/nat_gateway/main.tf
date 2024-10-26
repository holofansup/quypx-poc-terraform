resource "aws_eip" "nat" {
  tags = merge(
    var.global_resource_tags,
    var.tags,
    {
      Name : var.name
    }
  )
}

resource "aws_nat_gateway" "this" {
  subnet_id     = var.subnet_id
  allocation_id = aws_eip.nat.allocation_id

  tags = merge(
    var.global_resource_tags,
    var.tags,
    {
      Name : var.name
    }
  )
}