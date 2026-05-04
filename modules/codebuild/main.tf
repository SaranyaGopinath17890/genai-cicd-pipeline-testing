# -----------------------------------------------------------------------------
# CodeBuild Module — AWS CodeBuild Projects
# Creates a CodeBuild project for Docker image builds or Terraform operations.
#
# Features:
#   - Configurable compute type, image, and timeout
#   - Privileged mode for Docker-in-Docker builds
#   - Flexible environment variables (plaintext, Parameter Store, Secrets Manager)
#   - Optional S3 or local caching
#   - Optional VPC configuration
#   - CloudWatch Logs integration
#
# Requirements: 2.1, 2.2, 2.3, 2.4, 2.5
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "this" {
  name          = var.name
  description   = var.description
  service_role  = var.service_role_arn
  build_timeout = var.build_timeout

  # Source — when used with CodePipeline, source comes from the pipeline artifact
  source {
    type      = var.artifact_type == "CODEPIPELINE" ? "CODEPIPELINE" : "NO_SOURCE"
    buildspec = var.buildspec
  }

  # Artifacts — output goes back to CodePipeline or S3
  artifacts {
    type = var.artifact_type
  }

  # Build environment
  environment {
    compute_type    = var.compute_type
    image           = var.image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  # Logging
  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_log_group
      stream_name = var.cloudwatch_log_stream
    }
  }

  # Cache (optional)
  dynamic "cache" {
    for_each = var.cache_type != "NO_CACHE" ? [1] : []
    content {
      type     = var.cache_type
      location = var.cache_type == "S3" ? var.cache_location : null
      modes    = var.cache_type == "LOCAL" ? var.cache_modes : null
    }
  }

  # VPC configuration (optional)
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = var.tags
}
