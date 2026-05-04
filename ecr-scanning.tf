# -----------------------------------------------------------------------------
# ECR Image Security Scanning
# EventBridge rules for ECR scan events and SNS notifications.
#
# Requirements: 12.1, 12.2, 12.3, 12.4
# -----------------------------------------------------------------------------

variable "ecr_notification_type" {
  description = "ECR notification scope: scan_result, all, or none"
  type        = string
  default     = "scan_result"

  validation {
    condition     = contains(["scan_result", "all", "none"], var.ecr_notification_type)
    error_message = "ecr_notification_type must be one of: scan_result, all, none."
  }
}

# EventBridge rule for ECR scan completion events
resource "aws_cloudwatch_event_rule" "ecr_scan" {
  count = var.ecr_notification_type != "none" ? 1 : 0

  name        = "${local.name_prefix}-ecr-scan-events"
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

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "ecr_scan_sns" {
  count = var.ecr_notification_type != "none" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.ecr_scan[0].name
  target_id = "${local.name_prefix}-ecr-scan-sns"
  arn       = module.sns.topic_arn

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
