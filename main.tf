# -----------------------------------------------------------------------------
# Root Module — GenAI CI/CD Pipeline Composition
# Wires all modules together for the target environment.
#
# This file contains ONLY module calls and data sources.
# -----------------------------------------------------------------------------

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

# =============================================================================
# CodeConnection
# =============================================================================

module "codeconnection" {
  source = "./modules/codeconnection"

  name          = "${local.name_prefix}-${var.github_connection_name}"
  provider_type = "GitHub"
  tags          = local.common_tags
}

# =============================================================================
# Logging
# =============================================================================

module "logging" {
  source = "./modules/logging"

  name_prefix        = local.name_prefix
  log_retention_days = var.log_retention_days

  log_group_names = {
    codebuild_librechat = local.codebuild_log_group_librechat
    ecs_librechat       = local.ecs_log_group_librechat
  }

  tags = local.common_tags
}

# =============================================================================
# Shared Infrastructure
# =============================================================================

# IAM — roles for all pipeline components
module "iam" {
  source = "./modules/iam"

  name_prefix             = local.name_prefix
  codestar_connection_arn = module.codeconnection.connection_arn
  tags                    = local.common_tags
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
# Observability
# =============================================================================

module "observability" {
  source = "./modules/observability"

  name_prefix = local.name_prefix
  pipeline_names = [
    module.pipeline_librechat.pipeline_name,
  ]
  sns_topic_arn                = module.sns.topic_arn
  failure_rate_alarm_threshold = var.failure_rate_alarm_threshold
  failure_rate_alarm_period    = var.failure_rate_alarm_period
  aws_region                   = var.aws_region
  tags                         = local.common_tags
}

# =============================================================================
# LibreChat Pipeline
# =============================================================================

# ECR — LibreChat container image repository
module "ecr_librechat" {
  source = "./modules/ecr"

  name                  = "${local.name_prefix}-${var.librechat_ecr_repository_name}"
  scan_on_push          = true
  ecr_notification_type = var.ecr_notification_type
  sns_topic_arn         = module.sns.topic_arn
  tags                  = local.common_tags
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

  name                    = local.librechat_name
  container_image         = "${module.ecr_librechat.repository_url}:latest"
  container_port          = var.librechat_container_port
  cpu                     = var.librechat_cpu
  memory                  = var.librechat_memory
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn           = module.iam.ecs_task_role_arn

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
  codestar_connection_arn = module.codeconnection.connection_arn
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
