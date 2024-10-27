output "ecr_arns" {
  value = {
    for k, v in module.ecr : k => v.repository_arns
  }
}

output "ecr_uri" {
  value = {
    for k, v in module.ecr : k => v.repository_uri
  }
}