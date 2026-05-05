# -----------------------------------------------------------------------------
# SNS Module — Amazon Simple Notification Service
# Creates a shared SNS topic for all pipeline notifications with an email
# subscription and a topic policy allowing CodePipeline, CloudWatch Events,
# and CodeBuild to publish.
#
# Requirements: 6.1, 6.2, 6.3, 6.4
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_sns_topic" "this" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name}-policy"
    Statement = [
      # Allow CodePipeline to publish notifications
      {
        Sid    = "AllowCodePipelinePublish"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.this.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      # Allow CloudWatch Events / EventBridge to publish notifications
      {
        Sid    = "AllowEventsPublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.this.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      # Allow CodeBuild to publish notifications (for drift detection, scan alerts)
      {
        Sid    = "AllowCodeBuildPublish"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.this.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      # Allow AWS Budgets to publish cost alerts
      {
        Sid    = "AllowBudgetsPublish"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.this.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
