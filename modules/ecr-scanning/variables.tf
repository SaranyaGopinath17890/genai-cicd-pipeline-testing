# -----------------------------------------------------------------------------
# ECR Scanning Module — Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "ecr_notification_type" {
  description = "ECR notification scope: scan_result, all, or none"
  type        = string
  default     = "scan_result"

  validation {
    condition     = contains(["scan_result", "all", "none"], var.ecr_notification_type)
    error_message = "ecr_notification_type must be one of: scan_result, all, none."
  }
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
