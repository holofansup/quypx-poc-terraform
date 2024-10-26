output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = try(aws_iam_role.this.arn, "")
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = try(aws_iam_role.this.name, "")
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = try(aws_iam_role.this.path, "")
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = try(aws_iam_role.this.unique_id, "")
}

output "iam_instance_profile_arn" {
  description = "ARN of IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, "")
}

output "iam_instance_profile_name" {
  description = "Name of IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].name, "")
}

output "iam_instance_profile_id" {
  description = "IAM Instance profile's ID."
  value       = try(aws_iam_instance_profile.this[0].id, "")
}

output "iam_instance_profile_path" {
  description = "Path of IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].path, "")
}
