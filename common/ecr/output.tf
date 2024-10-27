output "repository_uri" {
  value = aws_ecr_repository.this.repository_url
}

output "repository_arns" {
  value = aws_ecr_repository.this.arn
}