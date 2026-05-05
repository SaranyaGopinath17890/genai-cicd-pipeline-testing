# -----------------------------------------------------------------------------
# Locals — naming conventions and common tags
# Provides consistent resource naming and tagging across all modules.
# -----------------------------------------------------------------------------

locals {
  # Naming prefix used across all resources: <project>-<environment>
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags applied to every resource
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Per-pipeline naming
  librechat_name = "${local.name_prefix}-librechat"

  # CloudWatch Log Groups
  codebuild_log_group_librechat = "/aws/codebuild/${local.librechat_name}-build"
  ecs_log_group_librechat       = "/ecs/${local.librechat_name}"
}
