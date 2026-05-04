# -----------------------------------------------------------------------------
# CodeBuild Module — Outputs
# Exposes project identifiers for consumption by pipeline modules.
# -----------------------------------------------------------------------------

output "project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.this.name
}

output "project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.this.arn
}

output "project_id" {
  description = "ID of the CodeBuild project"
  value       = aws_codebuild_project.this.id
}
