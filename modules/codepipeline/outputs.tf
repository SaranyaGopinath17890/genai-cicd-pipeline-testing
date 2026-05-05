# -----------------------------------------------------------------------------
# CodePipeline Module — Outputs
# Exposes pipeline identifiers for reference and monitoring.
# -----------------------------------------------------------------------------

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value = var.pipeline_type == "application" ? (
    length(aws_codepipeline.application) > 0 ? aws_codepipeline.application[0].arn : ""
    ) : (
    length(aws_codepipeline.terraform) > 0 ? aws_codepipeline.terraform[0].arn : ""
  )
}

output "pipeline_name" {
  description = "Name of the CodePipeline"
  value = var.pipeline_type == "application" ? (
    length(aws_codepipeline.application) > 0 ? aws_codepipeline.application[0].name : ""
    ) : (
    length(aws_codepipeline.terraform) > 0 ? aws_codepipeline.terraform[0].name : ""
  )
}

output "artifact_bucket_name" {
  description = "Name of the S3 artifact bucket"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the S3 artifact bucket"
  value       = aws_s3_bucket.artifacts.arn
}
