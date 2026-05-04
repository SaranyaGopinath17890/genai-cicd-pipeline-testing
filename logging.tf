# -----------------------------------------------------------------------------
# CloudWatch Log Groups
# Centralized logging for CodeBuild and ECS components.
#
# Requirements: 4.2, 6.4
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

# CodeBuild log groups
resource "aws_cloudwatch_log_group" "codebuild_librechat" {
  name              = local.codebuild_log_group_librechat
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "codebuild_admin_portal" {
  name              = local.codebuild_log_group_admin_portal
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "codebuild_terraform" {
  name              = local.codebuild_log_group_terraform
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

# ECS log groups
resource "aws_cloudwatch_log_group" "ecs_librechat" {
  name              = local.ecs_log_group_librechat
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_admin_portal" {
  name              = local.ecs_log_group_admin_portal
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}
