# -----------------------------------------------------------------------------
# ECR Module — Outputs
# Exposes repository identifiers and scan event rule for consumption by other modules.
# -----------------------------------------------------------------------------

output "repository_url" {
  description = "URL of the ECR repository (used in docker push/pull and ECS task definitions)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "Registry ID (AWS account ID) where the repository is hosted"
  value       = aws_ecr_repository.this.registry_id
}

output "scan_event_rule_arn" {
  description = "ARN of the ECR scan EventBridge rule (null if notifications disabled)"
  value       = var.ecr_notification_type != "none" ? aws_cloudwatch_event_rule.ecr_scan[0].arn : null
}
