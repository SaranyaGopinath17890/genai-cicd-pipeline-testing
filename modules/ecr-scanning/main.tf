# -----------------------------------------------------------------------------
# ECR Scanning Module
# EventBridge rules for ECR scan events and SNS notifications.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "ecr_scan" {
  count = var.ecr_notification_type != "none" ? 1 : 0

  name        = "${var.name_prefix}-ecr-scan-events"
  description = "Capture ECR image scan completion events"

  event_pattern = jsonencode(
    var.ecr_notification_type == "all" ? {
      source      = ["aws.ecr"]
      detail-type = ["ECR Image Scan", "ECR Image Action"]
      } : {
      source      = ["aws.ecr"]
      detail-type = ["ECR Image Scan"]
    }
  )

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "ecr_scan_sns" {
  count = var.ecr_notification_type != "none" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.ecr_scan[0].name
  target_id = "${var.name_prefix}-ecr-scan-sns"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      repo   = "$.detail.repository-name"
      digest = "$.detail.image-digest"
      status = "$.detail.scan-status"
      tags   = "$.detail.image-tags"
    }
    input_template = "\"ECR Scan Complete | Repo: <repo> | Tags: <tags> | Status: <status> | Digest: <digest>\""
  }
}
