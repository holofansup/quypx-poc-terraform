output "ecr_url" {
  value = {
    for k, v in module.ecr: 
    k => v.repository_url
  }
}