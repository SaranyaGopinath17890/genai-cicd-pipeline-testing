# -----------------------------------------------------------------------------
# Logging Module — Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

variable "log_group_names" {
  description = "Map of logical name to CloudWatch Log Group path"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to all log groups"
  type        = map(string)
}
