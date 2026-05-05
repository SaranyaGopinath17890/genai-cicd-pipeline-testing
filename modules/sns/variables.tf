# -----------------------------------------------------------------------------
# SNS Module — Variables
# Inputs for SNS topic and subscription configuration.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "notification_email" {
  description = "Email address to subscribe to the SNS topic for notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the SNS topic"
  type        = map(string)
}
