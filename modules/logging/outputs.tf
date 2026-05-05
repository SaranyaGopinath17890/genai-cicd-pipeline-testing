# -----------------------------------------------------------------------------
# Logging Module — Outputs
# -----------------------------------------------------------------------------

output "log_group_arns" {
  description = "Map of logical name to CloudWatch Log Group ARN"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "log_group_names" {
  description = "Map of logical name to CloudWatch Log Group name"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}
