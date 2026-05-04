# -----------------------------------------------------------------------------
# Secrets Module — AWS Secrets Manager and SSM Parameter Store
# Creates secrets and parameters for ECS task definitions to reference.
#
# Secrets Manager: sensitive credentials (DocumentDB connection string, API keys)
# Parameter Store: environment configuration (endpoints, feature flags)
#
# Requirements: 8.1, 8.2, 8.3, 8.4
# -----------------------------------------------------------------------------

# =============================================================================
# Secrets Manager
# =============================================================================

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name        = "${var.name_prefix}/${each.key}"
  description = each.value.description

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.secret_string
}

# =============================================================================
# SSM Parameter Store
# =============================================================================

resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name        = "/${var.name_prefix}/${each.key}"
  description = each.value.description
  type        = each.value.type
  value       = each.value.value

  tags = var.tags
}
