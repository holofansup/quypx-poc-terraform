output "id" {
  value = try(aws_route_table.this[0].id, null)
}
