# -----------------------------------------------------------------------------
# ECS Service Module — Variables
# Inputs for ECS task definitions and services.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name used for the ECS service, task definition family, and related resources"
  type        = string
}

# ---------------------------------------------------------------------------
# Task definition
# ---------------------------------------------------------------------------

variable "container_image" {
  description = "Docker image URI for the container (e.g., ECR repository URL with tag)"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU units for the Fargate task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Memory (MiB) for the Fargate task"
  type        = number
  default     = 2048
}

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution role (for pulling images and injecting secrets)"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role (for runtime permissions — EFS, S3, Bedrock)"
  type        = string
}

# ---------------------------------------------------------------------------
# Secrets and environment
# ---------------------------------------------------------------------------

variable "secrets" {
  description = <<-EOT
    List of secrets to inject from Secrets Manager into the container.
    Each item: { name = "ENV_VAR_NAME", valueFrom = "arn:aws:secretsmanager:..." }
  EOT
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "environment" {
  description = <<-EOT
    List of environment variables for the container.
    Each item: { name = "KEY", value = "VALUE" }
  EOT
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ---------------------------------------------------------------------------
# EFS volume mount
# ---------------------------------------------------------------------------

variable "efs_file_system_id" {
  description = "EFS file system ID for persistent storage (set to empty string to disable)"
  type        = string
  default     = ""
}

variable "efs_container_path" {
  description = "Container mount path for the EFS volume"
  type        = string
  default     = "/mnt/efs"
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

variable "log_group" {
  description = "CloudWatch Logs log group name for container logs"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch Logs configuration"
  type        = string
}

# ---------------------------------------------------------------------------
# Service configuration
# ---------------------------------------------------------------------------

variable "cluster_id" {
  description = "ID of the ECS cluster to deploy the service into"
  type        = string
}

variable "desired_count" {
  description = "Desired number of running tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the ECS tasks"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Load balancer
# ---------------------------------------------------------------------------

variable "target_group_arn" {
  description = "ARN of the ALB target group for health checks and traffic routing"
  type        = string
}

# ---------------------------------------------------------------------------
# Deployment
# ---------------------------------------------------------------------------

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during rolling deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks during rolling deployment"
  type        = number
  default     = 200
}

variable "enable_circuit_breaker" {
  description = "Whether to enable the ECS deployment circuit breaker"
  type        = bool
  default     = true
}

variable "enable_rollback" {
  description = "Whether to enable automatic rollback on circuit breaker trigger"
  type        = bool
  default     = true
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to wait before the ECS service starts checking ALB health"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to ECS resources"
  type        = map(string)
  default     = {}
}
