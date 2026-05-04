# -----------------------------------------------------------------------------
# Secrets Module — Outputs
# Exposes secret and parameter ARNs for ECS task definition references.
# -----------------------------------------------------------------------------

# Map of secret logical name → ARN (for ECS task definition `secrets` block)
output "secret_arns" {
  description = "Map of secret name to Secrets Manager secret ARN"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

# Map of parameter logical name → ARN (for ECS task definition `environment` block)
output "parameter_arns" {
  description = "Map of parameter name to SSM Parameter Store parameter ARN"
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}

# Flat list of all secret ARNs (for IAM policy resource lists)
output "all_secret_arns" {
  description = "List of all Secrets Manager secret ARNs created by this module"
  value       = [for v in aws_secretsmanager_secret.this : v.arn]
}

# Flat list of all parameter ARNs (for IAM policy resource lists)
output "all_parameter_arns" {
  description = "List of all SSM Parameter Store parameter ARNs created by this module"
  value       = [for v in aws_ssm_parameter.this : v.arn]
}
