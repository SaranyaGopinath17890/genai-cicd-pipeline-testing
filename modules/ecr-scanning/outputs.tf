# -----------------------------------------------------------------------------
# ECR Scanning Module — Outputs
# -----------------------------------------------------------------------------

output "event_rule_arn" {
  description = "ARN of the ECR scan EventBridge rule"
  value       = var.ecr_notification_type != "none" ? aws_cloudwatch_event_rule.ecr_scan[0].arn : null
}
