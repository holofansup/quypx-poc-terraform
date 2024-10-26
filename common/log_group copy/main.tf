data "aws_caller_identity" "caller" {}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = try(var.kms_key_id, null)
  skip_destroy      = false

  tags = merge(var.global_resource_tags, var.tags)
}

resource "aws_cloudwatch_log_resource_policy" "log_group_policy" {
  count           = try(var.policy_attached, false) == true ? 1 : 0
  policy_document = var.iam_policy_document_json
  policy_name     = var.log_group_policy_name
}

resource "aws_cloudwatch_log_subscription_filter" "log_subscription_filter" {
  count           = try(var.log_subscription_filter_enabled, false) == true ? 1 : 0
  name            = var.log_subscription_filter_name
  destination_arn = var.log_destination_arn
  filter_pattern  = try(var.log_filter_pattern, "")
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  role_arn        = try(var.kinesis_iam_role_arn, null)
  distribution    = try(var.distribution_method_to_destination, null)
}
