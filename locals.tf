# -----------------------------------------------------------------------------
# Locals — naming conventions and common tags
# Provides consistent resource naming and tagging across all modules.
# -----------------------------------------------------------------------------

locals {
  # Naming prefix used across all resources: <project>-<environment>
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags applied to every resource (in addition to provider default_tags)
  # NOTE: Do not include keys that conflict case-insensitively with default_tags
  # (e.g., "Project" conflicts with "PROJECT" in default_tags for IAM resources)
  common_tags = {
    ManagedBy = "terraform"
  }

  # Per-pipeline naming
  librechat_name = "${local.name_prefix}-librechat"

  # CloudWatch Log Groups
  codebuild_log_group_librechat = "/aws/codebuild/${local.librechat_name}-build"
  ecs_log_group_librechat       = "/ecs/${local.librechat_name}"
}
