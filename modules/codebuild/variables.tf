# -----------------------------------------------------------------------------
# CodeBuild Module — Variables
# Inputs for CodeBuild project configuration.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "description" {
  description = "Description of the CodeBuild project"
  type        = string
}

variable "service_role_arn" {
  description = "ARN of the IAM role for the CodeBuild project"
  type        = string
}

# ---------------------------------------------------------------------------
# Build environment
# ---------------------------------------------------------------------------

variable "compute_type" {
  description = "CodeBuild compute type (BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE)"
  type        = string
}

variable "image" {
  description = "Docker image for the build environment"
  type        = string
}

variable "privileged_mode" {
  description = "Whether to enable Docker daemon inside the build container (required for docker build)"
  type        = bool
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
}

# ---------------------------------------------------------------------------
# Source / buildspec
# ---------------------------------------------------------------------------

variable "buildspec" {
  description = "Path to the buildspec file relative to source root, or inline buildspec YAML"
  type        = string
}

# ---------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------

variable "environment_variables" {
  description = <<-EOT
    List of environment variables for the build.
    Each item: { name = "KEY", value = "VALUE", type = "PLAINTEXT|PARAMETER_STORE|SECRETS_MANAGER" }
  EOT
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "PLAINTEXT")
  }))
}

# ---------------------------------------------------------------------------
# Artifacts
# ---------------------------------------------------------------------------

variable "artifact_type" {
  description = "Type of build output artifact (CODEPIPELINE, S3, NO_ARTIFACTS)"
  type        = string
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

variable "cloudwatch_log_group" {
  description = "CloudWatch Logs log group name for build logs"
  type        = string
}

variable "cloudwatch_log_stream" {
  description = "CloudWatch Logs stream prefix for build logs"
  type        = string
}

# ---------------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------------

variable "cache_type" {
  description = "Cache type (NO_CACHE, S3, LOCAL)"
  type        = string
}

variable "cache_location" {
  description = "S3 bucket location for cache (required when cache_type is S3)"
  type        = string
}

variable "cache_modes" {
  description = "Cache modes for LOCAL cache type"
  type        = list(string)
}

# ---------------------------------------------------------------------------
# VPC (optional — needed if build needs VPC access)
# ---------------------------------------------------------------------------

variable "vpc_config" {
  description = "VPC configuration for CodeBuild (set to null to disable)"
  type = object({
    vpc_id             = string
    subnets            = list(string)
    security_group_ids = list(string)
  })
}

variable "tags" {
  description = "Tags to apply to the CodeBuild project"
  type        = map(string)
}
