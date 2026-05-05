# -----------------------------------------------------------------------------
# Drift Detection Module — Outputs
# -----------------------------------------------------------------------------

output "codebuild_project_arn" {
  description = "ARN of the drift detection CodeBuild project"
  value       = var.enabled ? aws_codebuild_project.drift_detection[0].arn : null
}

output "event_rule_arn" {
  description = "ARN of the EventBridge scheduled rule"
  value       = var.enabled ? aws_cloudwatch_event_rule.drift_detection[0].arn : null
}
