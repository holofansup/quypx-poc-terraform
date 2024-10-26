output "ids" {
  value = {
    for key, value in aws_security_group.this :
    key => value.id
  }
}