# -----------------------------------------------------------------------------
# Drift Detection Module
# Scheduled CodeBuild project triggered by EventBridge to detect
# infrastructure drift via terraform plan.
# -----------------------------------------------------------------------------

# CodeBuild project for drift detection
resource "aws_codebuild_project" "drift_detection" {
  count = var.enabled ? 1 : 0

  name          = "${var.name_prefix}-drift-detection"
  description   = "Daily drift detection via terraform plan -detailed-exitcode"
  service_role  = var.codebuild_role_arn
  build_timeout = 60

  source {
    type      = "NO_SOURCE"
    buildspec = "buildspecs/terraform-drift-buildspec.yml"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "TF_VERSION"
      value = "1.5.7"
    }

    environment_variable {
      name  = "TF_WORKING_DIR"
      value = "."
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "SNS_TOPIC_ARN"
      value = var.sns_topic_arn
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.name_prefix}-drift-detection"
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for drift detection
resource "aws_cloudwatch_log_group" "drift_detection" {
  count             = var.enabled ? 1 : 0
  name              = "/aws/codebuild/${var.name_prefix}-drift-detection"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# EventBridge scheduled rule
resource "aws_cloudwatch_event_rule" "drift_detection" {
  count = var.enabled ? 1 : 0

  name                = "${var.name_prefix}-drift-detection-schedule"
  description         = "Triggers daily drift detection via CodeBuild"
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "drift_detection" {
  count = var.enabled ? 1 : 0

  rule      = aws_cloudwatch_event_rule.drift_detection[0].name
  target_id = "${var.name_prefix}-drift-codebuild"
  arn       = aws_codebuild_project.drift_detection[0].arn
  role_arn  = aws_iam_role.eventbridge_codebuild.arn
}

# IAM role for EventBridge to start CodeBuild
resource "aws_iam_role" "eventbridge_codebuild" {
  name = "${var.name_prefix}-eventbridge-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "eventbridge_codebuild" {
  name = "${var.name_prefix}-eventbridge-codebuild-policy"
  role = aws_iam_role.eventbridge_codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "codebuild:StartBuild"
        Resource = var.enabled ? aws_codebuild_project.drift_detection[0].arn : "*"
      }
    ]
  })
}
