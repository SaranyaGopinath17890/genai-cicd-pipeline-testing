# -----------------------------------------------------------------------------
# TFVars Bucket Module — Outputs
# -----------------------------------------------------------------------------

output "bucket_arn" {
  description = "ARN of the TFVars S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Name of the TFVars S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_id" {
  description = "ID of the TFVars S3 bucket"
  value       = aws_s3_bucket.this.id
}
