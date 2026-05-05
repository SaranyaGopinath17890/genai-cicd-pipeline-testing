# -----------------------------------------------------------------------------
# CodePipeline Module — AWS CodePipeline
# Creates a CI/CD pipeline with configurable stages.
#
# Application pipeline: Source → Build → Deploy (ECS)
# Terraform pipeline:   Source → Validate → Plan → [Approval] → Apply
#
# Features:
#   - CodeConnection source stage for GitHub integration
#   - Configurable pipeline type (application or terraform)
#   - Optional manual approval gate for terraform pipelines
#   - EventBridge notification rules for pipeline state changes
#
# Requirements: 1.1, 1.2, 1.4, 2.1, 3.1, 5.1, 5.2, 5.3, 5.4, 5.5
# -----------------------------------------------------------------------------

# =============================================================================
# Artifact Store — S3 bucket for pipeline artifacts
# =============================================================================

resource "aws_s3_bucket" "artifacts" {
  bucket        = var.artifact_bucket_name
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================================
# Application Pipeline — Source → Build → Deploy
# =============================================================================

resource "aws_codepipeline" "application" {
  count = var.pipeline_type == "application" ? 1 : 0

  name     = var.name
  role_arn = var.role_arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  # Source Stage — GitHub via CodeConnection
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
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.repository
        BranchName       = var.branch
        DetectChanges    = var.detect_changes
      }
    }
  }

  # Build Stage — CodeBuild
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  # Approval Stage (conditional — between Build and Deploy)
  dynamic "stage" {
    for_each = var.require_manual_approval ? [1] : []
    content {
      name = "Approval"

      action {
        name               = "ManualApproval"
        category           = "Approval"
        owner              = "AWS"
        provider           = "Manual"
        version            = "1"
        timeout_in_minutes = var.approval_timeout_minutes

        configuration = {
          NotificationArn = var.approval_sns_topic_arn
          CustomData      = "Review the build output before deploying to ECS."
        }
      }
    }
  }

  # Deploy Stage — ECS
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = var.tags
}

# =============================================================================
# Terraform Pipeline — Source → Validate → Plan → [Approval] → Apply
# =============================================================================

resource "aws_codepipeline" "terraform" {
  count = var.pipeline_type == "terraform" ? 1 : 0

  name     = var.name
  role_arn = var.role_arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  # Source Stage
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
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.repository
        BranchName       = var.branch
        DetectChanges    = var.detect_changes
      }
    }
  }

  # Validate Stage (terraform validate + fmt check)
  dynamic "stage" {
    for_each = var.terraform_validate_project_name != "" ? [1] : []
    content {
      name = "Validate"

      action {
        name             = "Validate"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = ["source_output"]
        output_artifacts = ["validate_output"]

        configuration = {
          ProjectName = var.terraform_validate_project_name
        }
      }
    }
  }

  # Plan Stage
  stage {
    name = "Plan"

    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]

      configuration = {
        ProjectName = var.terraform_plan_project_name
      }
    }
  }

  # Approval Stage (conditional)
  dynamic "stage" {
    for_each = var.require_manual_approval ? [1] : []
    content {
      name = "Approval"

      action {
        name             = "ManualApproval"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        version          = "1"
        timeout_in_minutes = var.approval_timeout_minutes

        configuration = {
          NotificationArn = var.approval_sns_topic_arn
          CustomData      = "Review the Terraform plan output before approving."
        }
      }
    }
  }

  # Apply Stage
  stage {
    name = "Apply"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = var.terraform_apply_project_name
      }
    }
  }

  tags = var.tags
}

# =============================================================================
# EventBridge Notification Rules
# Captures pipeline state changes and routes to SNS
# =============================================================================

locals {
  # Determine which pipeline resource to reference
  pipeline_arn = var.pipeline_type == "application" ? (
    length(aws_codepipeline.application) > 0 ? aws_codepipeline.application[0].arn : ""
    ) : (
    length(aws_codepipeline.terraform) > 0 ? aws_codepipeline.terraform[0].arn : ""
  )

  pipeline_name = var.pipeline_type == "application" ? (
    length(aws_codepipeline.application) > 0 ? aws_codepipeline.application[0].name : ""
    ) : (
    length(aws_codepipeline.terraform) > 0 ? aws_codepipeline.terraform[0].name : ""
  )

  # Build event pattern based on notification_events setting
  notification_states = {
    both         = ["SUCCEEDED", "FAILED"]
    success_only = ["SUCCEEDED"]
    failure_only = ["FAILED"]
    every_stage  = ["STARTED", "SUCCEEDED", "FAILED", "STOPPED", "SUPERSEDED"]
  }

  create_notification = var.enable_notifications
}

resource "aws_cloudwatch_event_rule" "pipeline_events" {
  count = local.create_notification ? 1 : 0

  name        = "${var.name}-pipeline-events"
  description = "Capture ${var.name} pipeline state changes"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Stage Execution State Change"]
    detail = {
      pipeline = [local.pipeline_name]
      state    = local.notification_states[var.notification_events]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "pipeline_sns" {
  count = local.create_notification ? 1 : 0

  rule      = aws_cloudwatch_event_rule.pipeline_events[0].name
  target_id = "${var.name}-sns"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      pipeline  = "$.detail.pipeline"
      stage     = "$.detail.stage"
      state     = "$.detail.state"
      execution = "$.detail.execution-id"
      time      = "$.time"
    }
    input_template = "\"Pipeline: <pipeline> | Stage: <stage> | Status: <state> | Execution: <execution> | Time: <time>\""
  }
}
