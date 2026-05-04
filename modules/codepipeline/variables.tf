# -----------------------------------------------------------------------------
# CodePipeline Module — Variables
# Inputs for CI/CD pipeline configuration.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role for CodePipeline"
  type        = string
}

# ---------------------------------------------------------------------------
# Artifact store
# ---------------------------------------------------------------------------

variable "artifact_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts"
  type        = string
}

# ---------------------------------------------------------------------------
# Source stage
# ---------------------------------------------------------------------------

variable "codestar_connection_arn" {
  description = "ARN of the CodeConnection for GitHub"
  type        = string
}

variable "repository" {
  description = "GitHub repository in owner/repo format"
  type        = string
}

variable "branch" {
  description = "Branch to trigger the pipeline"
  type        = string
  default     = "dev"
}

variable "detect_changes" {
  description = "Whether the pipeline should automatically detect source changes"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Build stage
# ---------------------------------------------------------------------------

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project for the build stage"
  type        = string
}

# ---------------------------------------------------------------------------
# Deploy stage (ECS)
# ---------------------------------------------------------------------------

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster for deployment"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service for deployment"
  type        = string
}

# ---------------------------------------------------------------------------
# Pipeline type
# ---------------------------------------------------------------------------

variable "pipeline_type" {
  description = "Type of pipeline: 'application' (Source→Build→Deploy) or 'terraform' (Source→Validate→Plan→Approval→Apply)"
  type        = string
  default     = "application"

  validation {
    condition     = contains(["application", "terraform"], var.pipeline_type)
    error_message = "pipeline_type must be 'application' or 'terraform'."
  }
}

# ---------------------------------------------------------------------------
# Terraform pipeline stages (only used when pipeline_type = "terraform")
# ---------------------------------------------------------------------------

variable "terraform_plan_project_name" {
  description = "CodeBuild project name for terraform plan (terraform pipeline only)"
  type        = string
  default     = ""
}

variable "terraform_apply_project_name" {
  description = "CodeBuild project name for terraform apply (terraform pipeline only)"
  type        = string
  default     = ""
}

variable "terraform_validate_project_name" {
  description = "CodeBuild project name for terraform validate/fmt (terraform pipeline only)"
  type        = string
  default     = ""
}

variable "require_manual_approval" {
  description = "Whether to include a manual approval stage before apply (terraform pipeline only)"
  type        = bool
  default     = false
}

variable "approval_sns_topic_arn" {
  description = "SNS topic ARN for approval notifications (terraform pipeline only)"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Notifications
# ---------------------------------------------------------------------------

variable "sns_topic_arn" {
  description = "SNS topic ARN for pipeline event notifications"
  type        = string
  default     = ""
}

variable "notification_events" {
  description = "Which pipeline events generate notifications: both, success_only, failure_only, every_stage"
  type        = string
  default     = "both"

  validation {
    condition     = contains(["both", "success_only", "failure_only", "every_stage"], var.notification_events)
    error_message = "notification_events must be one of: both, success_only, failure_only, every_stage."
  }
}

variable "tags" {
  description = "Tags to apply to the CodePipeline"
  type        = map(string)
  default     = {}
}
