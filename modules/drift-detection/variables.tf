# -----------------------------------------------------------------------------
# Drift Detection Module — Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the IAM role for the CodeBuild project"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression for drift detection (cron or rate)"
  type        = string
  default     = "cron(0 6 * * ? *)"
}

variable "enabled" {
  description = "Whether to enable drift detection"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
