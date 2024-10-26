output "vpc" {
  value = module.vpc
}

output "subnet_ids" {
  value = {
    for key, value in module.subnet :
    key => value.id
  }
}

output "route_table_ids" {
  value = {
    for key, value in module.route_table :
    key => value.id
  }
}

output "security_group_ids" {
  value = module.security_group.ids
}

output "vpc_endpoints" {
  value = {
    for key, value in module.vpc_endpoint :
    key => value.id
  }
}
