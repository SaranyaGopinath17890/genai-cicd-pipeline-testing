# -----------------------------------------------------------------------------
# Root-level outputs
# Key resource identifiers for reference and cross-stack consumption.
# Additional outputs will be added as modules are wired in main.tf.
# -----------------------------------------------------------------------------

# CodeConnection
output "codestar_connection_arn" {
  description = "ARN of the CodeConnection for GitHub (must be confirmed manually in AWS Console)"
  value       = aws_codestarconnections_connection.github.arn
}

output "codestar_connection_status" {
  description = "Status of the CodeConnection (PENDING until manually confirmed)"
  value       = aws_codestarconnections_connection.github.connection_status
}
