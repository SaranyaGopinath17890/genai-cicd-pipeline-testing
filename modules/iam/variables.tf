# -----------------------------------------------------------------------------
# IAM Module — Variables
# Inputs for pipeline and ECS IAM roles and policies.
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Naming prefix for all IAM resources (e.g., genai-cicd-dev)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# S3 — Artifact bucket used by CodePipeline and CodeBuild
# ---------------------------------------------------------------------------

variable "s3_artifact_bucket_arn" {
  description = "ARN of the S3 bucket used for pipeline artifacts. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# ECR — Repositories that CodeBuild pushes to and ECS pulls from
# ---------------------------------------------------------------------------

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs. Pass empty list to use a wildcard."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# SNS — Topic for pipeline notifications
# ---------------------------------------------------------------------------

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for pipeline notifications. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# ECS — Cluster and services targeted by CodePipeline deploy actions
# ---------------------------------------------------------------------------

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# CodeBuild — Project ARNs that CodePipeline needs to start
# ---------------------------------------------------------------------------

variable "codebuild_project_arns" {
  description = "List of CodeBuild project ARNs that CodePipeline may start. Pass empty list to use a wildcard."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Secrets Manager — Secret ARNs that ECS tasks and CodeBuild may read
# ---------------------------------------------------------------------------

variable "secrets_manager_arns" {
  description = "List of Secrets Manager secret ARNs. Pass empty list to use a wildcard."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Parameter Store — Parameter ARNs that ECS tasks may read
# ---------------------------------------------------------------------------

variable "ssm_parameter_arns" {
  description = "List of SSM Parameter Store ARNs. Pass empty list to use a wildcard."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# CloudWatch Logs — Log group ARNs for CodeBuild and ECS
# ---------------------------------------------------------------------------

variable "cloudwatch_log_group_arns" {
  description = "List of CloudWatch Logs log group ARNs. Pass empty list to use a wildcard."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# EFS — File system ARN for ECS task role
# ---------------------------------------------------------------------------

variable "efs_file_system_arn" {
  description = "ARN of the EFS file system. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# S3 — Application data bucket ARN for ECS task role (distinct from artifact bucket)
# ---------------------------------------------------------------------------

variable "s3_data_bucket_arn" {
  description = "ARN of the S3 bucket for application data. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Terraform state — S3 bucket and DynamoDB table for Terraform pipeline
# ---------------------------------------------------------------------------

variable "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

variable "terraform_lock_table_arn" {
  description = "ARN of the DynamoDB table for Terraform state locking. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# CodeConnection — ARN for CodePipeline source actions
# ---------------------------------------------------------------------------

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar/CodeConnection for GitHub. Pass empty string to use a wildcard."
  type        = string
  default     = ""
}
