# -----------------------------------------------------------------------------
# Root-level variables for GenAI CI/CD Pipeline
# All environment-specific inputs are defined here to support replication
# across up to 30 distinct AWS accounts without structural module changes.
# -----------------------------------------------------------------------------

# -----------------------------------------------
# General
# -----------------------------------------------

variable "environment" {
  description = "Environment name (e.g., dev, stage, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "genai-cicd"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

# -----------------------------------------------
# Networking
# -----------------------------------------------

variable "vpc_id" {
  description = "VPC ID for the environment"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks and CodeBuild"
  type        = list(string)
}

# -----------------------------------------------
# GitHub / Source
# -----------------------------------------------

variable "github_connection_name" {
  description = "Name of the AWS CodeConnection for GitHub integration"
  type        = string
  default     = "github-connection"
}

variable "librechat_repo" {
  description = "GitHub repository for LibreChat (owner/repo format)"
  type        = string
}

variable "librechat_branch" {
  description = "Branch pattern to trigger the LibreChat pipeline"
  type        = string
  default     = "dev*"
}

variable "admin_portal_repo" {
  description = "GitHub repository for Admin Portal (owner/repo format)"
  type        = string
}

variable "admin_portal_branch" {
  description = "Branch pattern to trigger the Admin Portal pipeline"
  type        = string
  default     = "dev*"
}

variable "terraform_repo" {
  description = "GitHub repository for Terraform IaC (owner/repo format)"
  type        = string
}

variable "terraform_branch" {
  description = "Branch to trigger the Terraform pipeline"
  type        = string
  default     = "dev"
}

# -----------------------------------------------
# ECR
# -----------------------------------------------

variable "librechat_ecr_repository_name" {
  description = "ECR repository name for LibreChat container images"
  type        = string
  default     = "librechat"
}

variable "admin_portal_ecr_repository_name" {
  description = "ECR repository name for Admin Portal container images"
  type        = string
  default     = "admin-portal"
}

# -----------------------------------------------
# ECS / Compute
# -----------------------------------------------

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster (must already exist)"
  type        = string
  default     = ""
}

variable "librechat_container_port" {
  description = "Container port for the LibreChat application"
  type        = number
  default     = 8080
}

variable "admin_portal_container_port" {
  description = "Container port for the Admin Portal application"
  type        = number
  default     = 8080
}

variable "librechat_cpu" {
  description = "CPU units for the LibreChat ECS task"
  type        = number
  default     = 1024
}

variable "librechat_memory" {
  description = "Memory (MiB) for the LibreChat ECS task"
  type        = number
  default     = 2048
}

variable "admin_portal_cpu" {
  description = "CPU units for the Admin Portal ECS task"
  type        = number
  default     = 1024
}

variable "admin_portal_memory" {
  description = "Memory (MiB) for the Admin Portal ECS task"
  type        = number
  default     = 2048
}

# -----------------------------------------------
# Data & Storage
# -----------------------------------------------

variable "efs_file_system_id" {
  description = "EFS file system ID for persistent storage"
  type        = string
}

variable "docdb_cluster_endpoint" {
  description = "DocumentDB cluster endpoint"
  type        = string
}

variable "docdb_secret_arn" {
  description = "Secrets Manager ARN for DocumentDB credentials"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket for application assets"
  type        = string
}

# -----------------------------------------------
# GenAI
# -----------------------------------------------

variable "bedrock_model_id" {
  description = "Amazon Bedrock model ID for GenAI capabilities"
  type        = string
}

# -----------------------------------------------
# Notifications
# -----------------------------------------------

variable "notification_email" {
  description = "Email address for SNS pipeline notifications"
  type        = string
}

# -----------------------------------------------
# Pipeline behavior
# -----------------------------------------------

variable "require_manual_approval" {
  description = "Whether the Terraform pipeline requires manual approval before apply (false for dev, true for prod)"
  type        = bool
  default     = false
}

variable "github_token_secret_arn" {
  description = "Secrets Manager ARN for GitHub API token (used for PR comments). Leave empty to skip PR comments."
  type        = string
  default     = ""
}

variable "codebuild_timeout_minutes" {
  description = "Default timeout in minutes for application CodeBuild projects"
  type        = number
  default     = 30
}

variable "terraform_codebuild_timeout_minutes" {
  description = "Timeout in minutes for Terraform CodeBuild projects"
  type        = number
  default     = 60
}

# -----------------------------------------------
# Logging
# -----------------------------------------------

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

# -----------------------------------------------
# Drift Detection
# -----------------------------------------------

variable "drift_detection_schedule" {
  description = "EventBridge schedule expression for drift detection (cron or rate)"
  type        = string
  default     = "cron(0 6 * * ? *)"
}

variable "enable_drift_detection" {
  description = "Whether to enable drift detection"
  type        = bool
  default     = true
}

# -----------------------------------------------
# ECR Scanning
# -----------------------------------------------

variable "ecr_notification_type" {
  description = "ECR notification scope: scan_result, all, or none"
  type        = string
  default     = "scan_result"

  validation {
    condition     = contains(["scan_result", "all", "none"], var.ecr_notification_type)
    error_message = "ecr_notification_type must be one of: scan_result, all, none."
  }
}

# -----------------------------------------------
# Observability
# -----------------------------------------------

variable "failure_rate_alarm_threshold" {
  description = "Pipeline failure rate percentage threshold for CloudWatch alarm"
  type        = number
  default     = 50
}

variable "failure_rate_alarm_period" {
  description = "Evaluation period in seconds for the failure rate alarm"
  type        = number
  default     = 3600
}

# -----------------------------------------------
# TFVars Bucket
# -----------------------------------------------

variable "tfvars_bucket_name" {
  description = "S3 bucket name for TFVars storage (auto-generated if empty)"
  type        = string
  default     = ""
}

# -----------------------------------------------
# Tags
# -----------------------------------------------

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------
# UMass Mandatory Tags (Requirement 11)
# -----------------------------------------------

variable "uma_speed_type" {
  description = "UMass speed type tag value"
  type        = string
  default     = ""
}

variable "uma_function" {
  description = "UMass function tag value"
  type        = string
  default     = ""
}

variable "uma_creator" {
  description = "UMass creator tag value"
  type        = string
  default     = ""
}

variable "tag_arch" {
  description = "ARCH tag value"
  type        = string
  default     = "scalable"
}

variable "tag_org" {
  description = "ORG tag value"
  type        = string
  default     = "umass"
}

variable "tag_project" {
  description = "PROJECT tag value"
  type        = string
  default     = "genai"
}

# -----------------------------------------------
# Security Groups
# -----------------------------------------------

variable "ecs_security_group_ids" {
  description = "Security group IDs for ECS tasks"
  type        = list(string)
  default     = []
}

variable "codebuild_security_group_ids" {
  description = "Security group IDs for CodeBuild projects (if VPC access needed)"
  type        = list(string)
  default     = []
}

# -----------------------------------------------
# Load Balancer
# -----------------------------------------------

variable "librechat_target_group_arn" {
  description = "ARN of the ALB target group for LibreChat"
  type        = string
  default     = ""
}

variable "admin_portal_target_group_arn" {
  description = "ARN of the ALB target group for Admin Portal"
  type        = string
  default     = ""
}

# -----------------------------------------------
# ECS Cluster
# -----------------------------------------------

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster (if different from name)"
  type        = string
  default     = ""
}
