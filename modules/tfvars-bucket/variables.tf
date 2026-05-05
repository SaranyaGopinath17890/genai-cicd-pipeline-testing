# -----------------------------------------------------------------------------
# TFVars Bucket Module — Variables
# -----------------------------------------------------------------------------

variable "bucket_name" {
  description = "Name of the S3 bucket for TFVars storage"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild Terraform role that needs access to the bucket"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
