# -----------------------------------------------------------------------------
# Root-level outputs
# Key resource identifiers for reference and cross-stack consumption.
# -----------------------------------------------------------------------------

# =============================================================================
# CodeConnection
# =============================================================================

output "codestar_connection_arn" {
  description = "ARN of the CodeConnection for GitHub (must be confirmed manually in AWS Console)"
  value       = module.codeconnection.connection_arn
}

output "codestar_connection_status" {
  description = "Status of the CodeConnection (PENDING until manually confirmed)"
  value       = module.codeconnection.connection_status
}

# =============================================================================
# ECR Repositories
# =============================================================================

output "ecr_librechat_repository_url" {
  description = "ECR repository URL for LibreChat images"
  value       = module.ecr_librechat.repository_url
}

# =============================================================================
# Pipelines
# =============================================================================

output "pipeline_librechat_arn" {
  description = "ARN of the LibreChat CodePipeline"
  value       = module.pipeline_librechat.pipeline_arn
}

# =============================================================================
# ECS Services
# =============================================================================

output "ecs_librechat_service_name" {
  description = "Name of the LibreChat ECS service"
  value       = module.ecs_librechat.service_name
}

# =============================================================================
# SNS
# =============================================================================

output "sns_topic_arn" {
  description = "ARN of the shared SNS notification topic"
  value       = module.sns.topic_arn
}

# =============================================================================
# IAM Roles
# =============================================================================

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline service role"
  value       = module.iam.codepipeline_role_arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild service role (application builds)"
  value       = module.iam.codebuild_role_arn
}

# =============================================================================
# Logging
# =============================================================================

output "log_group_arns" {
  description = "Map of log group ARNs"
  value       = module.logging.log_group_arns
}

# =============================================================================
# Observability
# =============================================================================

output "dashboard_name" {
  description = "Name of the CloudWatch pipelines dashboard"
  value       = module.observability.dashboard_name
}

output "alarm_arns" {
  description = "ARNs of the pipeline failure rate alarms"
  value       = module.observability.alarm_arns
}

# =============================================================================
# ECR Scanning
# =============================================================================

output "ecr_scanning_rule_arn" {
  description = "ARN of the ECR scanning EventBridge rule for LibreChat"
  value       = module.ecr_librechat.scan_event_rule_arn
}
