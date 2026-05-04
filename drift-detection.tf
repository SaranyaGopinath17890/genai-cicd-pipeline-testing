# -----------------------------------------------------------------------------
# Drift Detection
# Scheduled CodeBuild project triggered by EventBridge to detect
# infrastructure drift via terraform plan.
#
# Requirements: 14.1, 14.2, 14.3, 14.4
# -----------------------------------------------------------------------------

variable "drift_detection_schedule" {
  description = "EventBridge schedule expression for drift detection (cron or rate)"
  type        = string
  default     = "cron(0 6 * * ? *)"
}

variable "enable_drift_detection" {
  description = "Whether to enable drift detection"
  type        = bool
  default     = true
}

# CodeBuild — Drift detection project
module "codebuild_drift_detection" {
  count  = var.enable_drift_detection ? 1 : 0
  source = "./modules/codebuild"

  name             = "${local.terraform_name}-drift-detection"
  description      = "Daily drift detection via terraform plan -detailed-exitcode"
  service_role_arn = module.iam.codebuild_terraform_role_arn
  buildspec        = "buildspecs/terraform-drift-buildspec.yml"
  privileged_mode  = false

  environment_variables = [
    { name = "TF_VERSION", value = "1.5.7" },
    { name = "TF_WORKING_DIR", value = "." },
    { name = "AWS_DEFAULT_REGION", value = var.aws_region },
    { name = "SNS_TOPIC_ARN", value = module.sns.topic_arn },
  ]

  cloudwatch_log_group = "/aws/codebuild/${local.terraform_name}-drift-detection"
  tags                 = local.common_tags
}

# CloudWatch Log Group for drift detection
resource "aws_cloudwatch_log_group" "drift_detection" {
  count             = var.enable_drift_detection ? 1 : 0
  name              = "/aws/codebuild/${local.terraform_name}-drift-detection"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

# EventBridge scheduled rule
resource "aws_cloudwatch_event_rule" "drift_detection" {
  count = var.enable_drift_detection ? 1 : 0

  name                = "${local.terraform_name}-drift-detection-schedule"
  description         = "Triggers daily drift detection via CodeBuild"
  schedule_expression = var.drift_detection_schedule
  tags                = local.common_tags
}

resource "aws_cloudwatch_event_target" "drift_detection" {
  count = var.enable_drift_detection ? 1 : 0

  rule      = aws_cloudwatch_event_rule.drift_detection[0].name
  target_id = "${local.terraform_name}-drift-codebuild"
  arn       = module.codebuild_drift_detection[0].project_arn
  role_arn  = aws_iam_role.eventbridge_codebuild.arn
}

# IAM role for EventBridge to start CodeBuild
resource "aws_iam_role" "eventbridge_codebuild" {
  name = "${local.name_prefix}-eventbridge-codebuild-role"

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

  tags = local.common_tags
}

resource "aws_iam_role_policy" "eventbridge_codebuild" {
  name = "${local.name_prefix}-eventbridge-codebuild-policy"
  role = aws_iam_role.eventbridge_codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "codebuild:StartBuild"
        Resource = var.enable_drift_detection ? module.codebuild_drift_detection[0].project_arn : "*"
      }
    ]
  })
}
