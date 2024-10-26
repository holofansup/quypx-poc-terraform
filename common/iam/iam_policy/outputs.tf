output "id" {
  description = "The policy's ID"
  value       = try(aws_iam_policy.iam_policy.id, "")
}

output "arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = try(aws_iam_policy.iam_policy.arn, "")
}

output "description" {
  description = "The description of the policy"
  value       = try(aws_iam_policy.iam_policy.description, "")
}

output "name" {
  description = "The name of the policy"
  value       = try(aws_iam_policy.iam_policy.name, "")
}

output "path" {
  description = "The path of the policy in IAM"
  value       = try(aws_iam_policy.iam_policy.path, "")
}

output "policy" {
  description = "The policy document"
  value       = try(aws_iam_policy.iam_policy.policy, "")
}
