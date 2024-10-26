resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostname

  tags = merge(
    var.global_resource_tags,
    var.tags,
    {
      Name : var.name
    }
  )
}
