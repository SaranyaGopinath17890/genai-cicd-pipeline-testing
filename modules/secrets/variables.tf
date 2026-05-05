# -----------------------------------------------------------------------------
# Secrets Module — Variables
# Inputs for Secrets Manager and Parameter Store resources.
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Naming prefix for all secret and parameter resources (e.g., genai-cicd-dev)"
  type        = string
}

# ---------------------------------------------------------------------------
# Secrets Manager — sensitive values (credentials, API keys)
# ---------------------------------------------------------------------------

variable "secrets" {
  description = <<-EOT
    Map of secrets to create in Secrets Manager.
    Key   = logical name (used in resource naming and output map)
    Value = object with:
      - description: human-readable description
      - secret_string: the secret value (sensitive)
    Example:
      secrets = {
        docdb-connection-string = {
          description   = "DocumentDB connection string"
          secret_string = "mongodb://user:pass@host:27017"
        }
      }
  EOT
  type = map(object({
    description   = string
    secret_string = string
  }))
}

# ---------------------------------------------------------------------------
# Parameter Store — non-sensitive configuration values
# ---------------------------------------------------------------------------

variable "parameters" {
  description = <<-EOT
    Map of parameters to create in SSM Parameter Store.
    Key   = logical name (used as the parameter path suffix)
    Value = object with:
      - description: human-readable description
      - type: parameter type (String, StringList, or SecureString)
      - value: the parameter value
    Example:
      parameters = {
        bedrock-model-id = {
          description = "Amazon Bedrock model ID"
          type        = "String"
          value       = "anthropic.claude-3-sonnet-20240229-v1:0"
        }
      }
  EOT
  type = map(object({
    description = string
    type        = string
    value       = string
  }))
}

variable "tags" {
  description = "Tags to apply to all secrets and parameters"
  type        = map(string)
}
