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
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "genai-cicd"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------
# Networking
# -----------------------------------------------

variable "vpc_id" {
  description = "VPC ID for the environment"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks and CodeBuild"
  type        = list(string)
  default     = []
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
  default     = ""
}

variable "librechat_branch" {
  description = "Branch pattern to trigger the LibreChat pipeline"
  type        = string
  default     = "main"
}

# -----------------------------------------------
# ECR
# -----------------------------------------------

variable "librechat_ecr_repository_name" {
  description = "ECR repository name for LibreChat container images"
  type        = string
  default     = "librechat"
}

# -----------------------------------------------
# ECS / Compute
# -----------------------------------------------

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = ""
}

variable "librechat_container_port" {
  description = "Container port for the LibreChat application"
  type        = number
  default     = 80
}

variable "librechat_cpu" {
  description = "CPU units for the LibreChat ECS task"
  type        = number
  default     = 256
}

variable "librechat_memory" {
  description = "Memory (MiB) for the LibreChat ECS task"
  type        = number
  default     = 512
}

# -----------------------------------------------
# Data & Storage
# -----------------------------------------------

variable "efs_file_system_id" {
  description = "EFS file system ID for persistent storage"
  type        = string
  default     = ""
}

variable "docdb_cluster_endpoint" {
  description = "DocumentDB cluster endpoint"
  type        = string
  default     = ""
}

variable "docdb_secret_arn" {
  description = "Secrets Manager ARN for DocumentDB credentials"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "S3 bucket for application assets"
  type        = string
  default     = ""
}

# -----------------------------------------------
# GenAI
# -----------------------------------------------

variable "bedrock_model_id" {
  description = "Amazon Bedrock model ID for GenAI capabilities"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

# -----------------------------------------------
# Notifications
# -----------------------------------------------

variable "notification_email" {
  description = "Email address for SNS pipeline notifications"
  type        = string
  default     = ""
}

# -----------------------------------------------
# Pipeline behavior
# -----------------------------------------------

variable "docker_build_context" {
  description = "Docker build context path passed to CodeBuild"
  type        = string
  default     = "apps/librechat"
}

variable "codebuild_timeout_minutes" {
  description = "Default timeout in minutes for application CodeBuild projects"
  type        = number
  default     = 30
}

variable "require_manual_approval" {
  description = "Whether the pipeline requires manual approval before deploy"
  type        = bool
  default     = false
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
# UMass Mandatory Tags
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

# -----------------------------------------------
# Project Tags
# -----------------------------------------------

variable "tag_arch" {
  description = "ARCH tag value"
  type        = string
  default     = "scalable"
}

variable "tag_env" {
  description = "ENV tag value"
  type        = string
  default     = "dev"
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

# -----------------------------------------------
# ECS Cluster
# -----------------------------------------------

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster (if different from name)"
  type        = string
  default     = ""
}
