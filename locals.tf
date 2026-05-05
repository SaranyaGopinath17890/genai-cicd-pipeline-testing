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
  librechat_name    = "${local.name_prefix}-librechat"
  admin_portal_name = "${local.name_prefix}-admin-portal"
  terraform_name    = "${local.name_prefix}-terraform"

  # CloudWatch Log Groups
  codebuild_log_group_librechat    = "/aws/codebuild/${local.librechat_name}-build"
  codebuild_log_group_admin_portal = "/aws/codebuild/${local.admin_portal_name}-build"
  codebuild_log_group_terraform    = "/aws/codebuild/${local.terraform_name}-plan-apply"
  ecs_log_group_librechat          = "/ecs/${local.librechat_name}"
  ecs_log_group_admin_portal       = "/ecs/${local.admin_portal_name}"

  # TFVars are stored in the same S3 bucket as the state backend
  tfvars_bucket_name = "umass-genai-terraform-state"
}
