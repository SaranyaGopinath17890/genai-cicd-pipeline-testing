# -----------------------------------------------------------------------------
# ECR Module — Amazon Elastic Container Registry
# Creates an ECR repository with lifecycle policies for image retention.
#
# Features:
#   - Scan on push (configurable)
#   - Lifecycle policy: retain N tagged images, expire untagged after N days
#   - Configurable tag mutability
#
# Requirements: 2.2, 4.4
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
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
          tagStatus      = "tagged"
          tagPrefixList  = var.tagged_prefix_list
          countType      = "imageCountMoreThan"
          countNumber    = var.max_tagged_image_count
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
