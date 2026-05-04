# -----------------------------------------------------------------------------
# Root Module — GenAI CI/CD Pipeline Composition
# Wires all modules together for the target environment.
#
# This file instantiates:
#   - IAM roles (shared across all pipelines)
#   - SNS topic (shared notifications)
#   - Secrets Manager + Parameter Store entries
#   - ECR repositories (LibreChat, Admin Portal)
#   - CodeBuild projects (LibreChat, Admin Portal)
#   - ECS services (LibreChat, Admin Portal)
#   - CodePipelines (LibreChat, Admin Portal)
#
# The Terraform pipeline is instantiated separately in Task 11.
# -----------------------------------------------------------------------------

# =============================================================================
# Shared Infrastructure
# =============================================================================

# IAM — roles for all pipeline components
module "iam" {
  source = "./modules/iam"

  name_prefix            = local.name_prefix
  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  tags                   = local.common_tags
}

# SNS — shared notification topic
module "sns" {
  source = "./modules/sns"

  name               = "${local.name_prefix}-pipeline-notifications"
  notification_email = var.notification_email
  tags               = local.common_tags
}

# Secrets — application secrets and configuration
module "secrets" {
  source = "./modules/secrets"

  name_prefix = local.name_prefix

  secrets = {
    docdb-connection-string = {
      description   = "DocumentDB connection string"
      secret_string = var.docdb_cluster_endpoint
    }
  }

  parameters = {
    bedrock-model-id = {
      description = "Amazon Bedrock model ID"
      type        = "String"
      value       = var.bedrock_model_id
    }
    environment = {
      description = "Current environment name"
      type        = "String"
      value       = var.environment
    }
  }

  tags = local.common_tags
}

# =============================================================================
# LibreChat Pipeline
# =============================================================================

# ECR — LibreChat container image repository
module "ecr_librechat" {
  source = "./modules/ecr"

  name         = "${local.name_prefix}-${var.librechat_ecr_repository_name}"
  scan_on_push = true
  tags         = local.common_tags
}

# CodeBuild — LibreChat image build project
module "codebuild_librechat" {
  source = "./modules/codebuild"

  name             = "${local.librechat_name}-build"
  description      = "Builds Docker images for the LibreChat application"
  service_role_arn = module.iam.codebuild_role_arn
  buildspec        = "buildspecs/app-buildspec.yml"
  privileged_mode  = true
  build_timeout    = var.codebuild_timeout_minutes

  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
    { name = "AWS_ACCOUNT_ID", value = data.aws_caller_identity.current.account_id },
    { name = "ECR_REPOSITORY_NAME", value = module.ecr_librechat.repository_name },
    { name = "CONTAINER_NAME", value = local.librechat_name },
  ]

  cloudwatch_log_group = local.codebuild_log_group_librechat
  tags                 = local.common_tags
}

# ECS — LibreChat service
module "ecs_librechat" {
  source = "./modules/ecs-service"

  name                   = local.librechat_name
  container_image        = "${module.ecr_librechat.repository_url}:latest"
  container_port         = var.librechat_container_port
  cpu                    = var.librechat_cpu
  memory                 = var.librechat_memory
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn

  secrets = [
    { name = "DOCDB_CONNECTION_STRING", valueFrom = module.secrets.secret_arns["docdb-connection-string"] },
  ]

  environment = [
    { name = "ENV", value = var.environment },
    { name = "BEDROCK_MODEL_ID", value = var.bedrock_model_id },
  ]

  efs_file_system_id = var.efs_file_system_id
  log_group          = local.ecs_log_group_librechat
  aws_region         = var.aws_region

  cluster_id         = var.ecs_cluster_id != "" ? var.ecs_cluster_id : var.ecs_cluster_name
  subnet_ids         = var.subnet_ids
  security_group_ids = var.ecs_security_group_ids
  target_group_arn   = var.librechat_target_group_arn

  tags = local.common_tags
}

# CodePipeline — LibreChat CI/CD pipeline
module "pipeline_librechat" {
  source = "./modules/codepipeline"

  name                    = "${local.librechat_name}-pipeline"
  role_arn                = module.iam.codepipeline_role_arn
  artifact_bucket_name    = "${local.librechat_name}-artifacts"
  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = var.librechat_repo
  branch                  = var.librechat_branch
  codebuild_project_name  = module.codebuild_librechat.project_name
  ecs_cluster_name        = var.ecs_cluster_name
  ecs_service_name        = module.ecs_librechat.service_name
  pipeline_type           = "application"
  sns_topic_arn           = module.sns.topic_arn
  notification_events     = "both"
  tags                    = local.common_tags
}

# =============================================================================
# Admin Portal Pipeline
# =============================================================================

# ECR — Admin Portal container image repository
module "ecr_admin_portal" {
  source = "./modules/ecr"

  name         = "${local.name_prefix}-${var.admin_portal_ecr_repository_name}"
  scan_on_push = true
  tags         = local.common_tags
}

# CodeBuild — Admin Portal image build project
module "codebuild_admin_portal" {
  source = "./modules/codebuild"

  name             = "${local.admin_portal_name}-build"
  description      = "Builds Docker images for the Admin Portal application"
  service_role_arn = module.iam.codebuild_role_arn
  buildspec        = "buildspecs/app-buildspec.yml"
  privileged_mode  = true
  build_timeout    = var.codebuild_timeout_minutes

  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
    { name = "AWS_ACCOUNT_ID", value = data.aws_caller_identity.current.account_id },
    { name = "ECR_REPOSITORY_NAME", value = module.ecr_admin_portal.repository_name },
    { name = "CONTAINER_NAME", value = local.admin_portal_name },
  ]

  cloudwatch_log_group = local.codebuild_log_group_admin_portal
  tags                 = local.common_tags
}

# ECS — Admin Portal service
module "ecs_admin_portal" {
  source = "./modules/ecs-service"

  name                   = local.admin_portal_name
  container_image        = "${module.ecr_admin_portal.repository_url}:latest"
  container_port         = var.admin_portal_container_port
  cpu                    = var.admin_portal_cpu
  memory                 = var.admin_portal_memory
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn

  secrets = [
    { name = "DOCDB_CONNECTION_STRING", valueFrom = module.secrets.secret_arns["docdb-connection-string"] },
  ]

  environment = [
    { name = "ENV", value = var.environment },
  ]

  efs_file_system_id = ""
  log_group          = local.ecs_log_group_admin_portal
  aws_region         = var.aws_region

  cluster_id         = var.ecs_cluster_id != "" ? var.ecs_cluster_id : var.ecs_cluster_name
  subnet_ids         = var.subnet_ids
  security_group_ids = var.ecs_security_group_ids
  target_group_arn   = var.admin_portal_target_group_arn

  tags = local.common_tags
}

# CodePipeline — Admin Portal CI/CD pipeline
module "pipeline_admin_portal" {
  source = "./modules/codepipeline"

  name                    = "${local.admin_portal_name}-pipeline"
  role_arn                = module.iam.codepipeline_role_arn
  artifact_bucket_name    = "${local.admin_portal_name}-artifacts"
  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = var.admin_portal_repo
  branch                  = var.admin_portal_branch
  codebuild_project_name  = module.codebuild_admin_portal.project_name
  ecs_cluster_name        = var.ecs_cluster_name
  ecs_service_name        = module.ecs_admin_portal.service_name
  pipeline_type           = "application"
  sns_topic_arn           = module.sns.topic_arn
  notification_events     = "both"
  tags                    = local.common_tags
}

# =============================================================================
# Terraform Pipeline
# =============================================================================

# CodeBuild — Terraform validate/fmt
module "codebuild_terraform_validate" {
  source = "./modules/codebuild"

  name             = "${local.terraform_name}-validate"
  description      = "Runs terraform validate and fmt -check"
  service_role_arn = module.iam.codebuild_terraform_role_arn
  buildspec        = "buildspecs/terraform-validate-buildspec.yml"
  privileged_mode  = false
  build_timeout    = var.terraform_codebuild_timeout_minutes

  environment_variables = [
    { name = "TF_VERSION", value = "1.5.7" },
    { name = "TF_WORKING_DIR", value = "." },
  ]

  cloudwatch_log_group = local.codebuild_log_group_terraform
  tags                 = local.common_tags
}

# CodeBuild — Terraform plan
module "codebuild_terraform_plan" {
  source = "./modules/codebuild"

  name             = "${local.terraform_name}-plan"
  description      = "Runs terraform init and terraform plan"
  service_role_arn = module.iam.codebuild_terraform_role_arn
  buildspec        = "buildspecs/terraform-plan-buildspec.yml"
  privileged_mode  = false
  build_timeout    = var.terraform_codebuild_timeout_minutes

  # S3 cache for .terraform provider directory
  cache_type     = "S3"
  cache_location = "${module.pipeline_terraform.artifact_bucket_name}/codebuild-cache/terraform"

  environment_variables = [
    { name = "TF_VERSION", value = "1.5.7" },
    { name = "TF_WORKING_DIR", value = "." },
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
    { name = "GITHUB_TOKEN_SECRET_ARN", value = var.github_token_secret_arn },
    { name = "GITHUB_REPO", value = var.terraform_repo },
    { name = "TFVARS_BUCKET", value = local.tfvars_bucket_name },
    { name = "ENVIRONMENT", value = var.environment },
  ]

  cloudwatch_log_group = local.codebuild_log_group_terraform
  tags                 = local.common_tags
}

# CodeBuild — Terraform apply
module "codebuild_terraform_apply" {
  source = "./modules/codebuild"

  name             = "${local.terraform_name}-apply"
  description      = "Runs terraform apply after approval"
  service_role_arn = module.iam.codebuild_terraform_role_arn
  buildspec        = "buildspecs/terraform-apply-buildspec.yml"
  privileged_mode  = false
  build_timeout    = var.terraform_codebuild_timeout_minutes

  # S3 cache for .terraform provider directory
  cache_type     = "S3"
  cache_location = "${module.pipeline_terraform.artifact_bucket_name}/codebuild-cache/terraform"

  environment_variables = [
    { name = "TF_VERSION", value = "1.5.7" },
    { name = "TF_WORKING_DIR", value = "." },
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
    { name = "TFVARS_BUCKET", value = local.tfvars_bucket_name },
    { name = "ENVIRONMENT", value = var.environment },
  ]

  cloudwatch_log_group = local.codebuild_log_group_terraform
  tags                 = local.common_tags
}

# CodePipeline — Terraform pipeline (Source → Plan → [Approval] → Apply)
module "pipeline_terraform" {
  source = "./modules/codepipeline"

  name                    = "${local.terraform_name}-pipeline"
  role_arn                = module.iam.codepipeline_role_arn
  artifact_bucket_name    = "${local.terraform_name}-artifacts"
  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = var.terraform_repo
  branch                  = var.terraform_branch
  pipeline_type           = "terraform"

  # Terraform-specific stages
  terraform_validate_project_name = module.codebuild_terraform_validate.project_name
  terraform_plan_project_name     = module.codebuild_terraform_plan.project_name
  terraform_apply_project_name    = module.codebuild_terraform_apply.project_name

  # Approval gate — false for dev, true for prod
  require_manual_approval = var.require_manual_approval
  approval_sns_topic_arn  = module.sns.topic_arn

  # Notifications
  sns_topic_arn       = module.sns.topic_arn
  notification_events = "both"

  tags = local.common_tags
}

# =============================================================================
# Terraform Destroy Safeguard Pipeline
# Manual trigger only — never triggered by commits or schedules.
# Always requires approval regardless of require_manual_approval setting.
# Requirements: 13.4, 13.5
# =============================================================================

# CodeBuild — Terraform destroy
module "codebuild_terraform_destroy" {
  source = "./modules/codebuild"

  name             = "${local.terraform_name}-destroy"
  description      = "Runs terraform destroy (manual trigger with mandatory approval)"
  service_role_arn = module.iam.codebuild_terraform_role_arn
  buildspec        = "buildspecs/terraform-destroy-buildspec.yml"
  privileged_mode  = false

  environment_variables = [
    { name = "TF_VERSION", value = "1.5.7" },
    { name = "TF_WORKING_DIR", value = "." },
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
  ]

  cloudwatch_log_group = local.codebuild_log_group_terraform
  tags                 = local.common_tags
}

# Destroy pipeline — Source → Approval (mandatory) → Destroy
resource "aws_codepipeline" "terraform_destroy" {
  name     = "${local.terraform_name}-destroy-pipeline"
  role_arn = module.iam.codepipeline_role_arn

  artifact_store {
    location = module.pipeline_terraform.artifact_bucket_name
    type     = "S3"
  }

  # Source Stage — same repo, but detect_changes = false (no auto-trigger)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.terraform_repo
        BranchName       = var.terraform_branch
        DetectChanges    = false
      }
    }
  }

  # Mandatory Approval — always required regardless of environment
  stage {
    name = "Approval"

    action {
      name     = "MandatoryApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = module.sns.topic_arn
        CustomData      = "WARNING: This will DESTROY all infrastructure. Review carefully before approving."
      }
    }
  }

  # Destroy Stage
  stage {
    name = "Destroy"

    action {
      name            = "TerraformDestroy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = module.codebuild_terraform_destroy.project_name
      }
    }
  }

  tags = local.common_tags
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}
