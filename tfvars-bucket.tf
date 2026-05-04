# -----------------------------------------------------------------------------
# TFVars S3 Bucket
# Centralized storage for .tfvars files per environment.
# Created on initial deployment, reused on subsequent runs.
#
# Requirements: 19.1, 19.2, 19.3, 19.4
# -----------------------------------------------------------------------------

variable "tfvars_bucket_name" {
  description = "S3 bucket name for TFVars storage (auto-generated if empty)"
  type        = string
  default     = ""
}

locals {
  tfvars_bucket_name = var.tfvars_bucket_name != "" ? var.tfvars_bucket_name : "${local.name_prefix}-tfvars"
}

resource "aws_s3_bucket" "tfvars" {
  bucket = local.tfvars_bucket_name

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfvars" {
  bucket = aws_s3_bucket.tfvars.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfvars" {
  bucket = aws_s3_bucket.tfvars.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfvars" {
  bucket = aws_s3_bucket.tfvars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tfvars" {
  bucket = aws_s3_bucket.tfvars.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowTerraformPipelineAccess"
        Effect    = "Allow"
        Principal = {
          AWS = module.iam.codebuild_terraform_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.tfvars.arn,
          "${aws_s3_bucket.tfvars.arn}/*"
        ]
      }
    ]
  })
}
