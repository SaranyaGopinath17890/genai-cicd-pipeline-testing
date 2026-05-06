# -----------------------------------------------------------------------------
# ECR Module — Amazon Elastic Container Registry
# Creates an ECR repository with lifecycle policies and scan event notifications.
#
# Features:
#   - Scan on push (configurable)
#   - Lifecycle policy: retain N tagged images, expire untagged after N days
#   - Configurable tag mutability
#   - EventBridge rules for scan result notifications via SNS
# -----------------------------------------------------------------------------

# =============================================================================
# ECR Repository
# =============================================================================

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_tagged_image_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = var.tagged_prefix_list
          countType     = "imageCountMoreThan"
          countNumber   = var.max_tagged_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images after ${var.untagged_image_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiry_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# =============================================================================
# ECR Scan Event Notifications
# =============================================================================

resource "aws_cloudwatch_event_rule" "ecr_scan" {
  count = var.ecr_notification_type != "none" ? 1 : 0

  name        = "${var.name}-ecr-scan-events"
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
  target_id = "${var.name}-ecr-scan-sns"
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
