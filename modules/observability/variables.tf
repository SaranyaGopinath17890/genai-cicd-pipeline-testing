# -----------------------------------------------------------------------------
# Observability Module — Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "pipeline_names" {
  description = "List of pipeline names to monitor [librechat, admin_portal, terraform]"
  type        = list(string)
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "failure_rate_alarm_threshold" {
  description = "Pipeline failure rate percentage threshold for CloudWatch alarm"
  type        = number
}

variable "failure_rate_alarm_period" {
  description = "Evaluation period in seconds for the failure rate alarm"
  type        = number
}

variable "aws_region" {
  description = "AWS region for CloudWatch dashboard metrics"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
