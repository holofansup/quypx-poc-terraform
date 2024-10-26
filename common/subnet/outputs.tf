output "id" {
  value = try(aws_subnet.this[0].id, null)
}

output "arn" {
  value = try(aws_subnet.this[0].arn, null)
}