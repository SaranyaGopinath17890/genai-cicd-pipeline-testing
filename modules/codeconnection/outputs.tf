# -----------------------------------------------------------------------------
# CodeConnection Module — Outputs
# -----------------------------------------------------------------------------

output "connection_arn" {
  description = "ARN of the CodeStar connection"
  value       = aws_codestarconnections_connection.this.arn
}

output "connection_name" {
  description = "Name of the CodeStar connection"
  value       = aws_codestarconnections_connection.this.name
}

output "connection_status" {
  description = "Status of the CodeStar connection"
  value       = aws_codestarconnections_connection.this.connection_status
}
