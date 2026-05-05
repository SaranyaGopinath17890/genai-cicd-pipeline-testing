# Module: secrets

## Purpose

Creates AWS Secrets Manager secrets and SSM Parameter Store parameters for ECS task definitions to reference at container startup.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Naming prefix for resources | string | — | yes |
| `secrets` | Map of secrets (name → {description, secret_string}) | map(object) | {} | no |
| `parameters` | Map of parameters (name → {description, type, value}) | map(object) | {} | no |
| `tags` | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `secret_arns` | Map of secret name → ARN |
| `parameter_arns` | Map of parameter name → ARN |
| `all_secret_arns` | Flat list of all secret ARNs |
| `all_parameter_arns` | Flat list of all parameter ARNs |

## Usage Example

```hcl
module "secrets" {
  source      = "./modules/secrets"
  name_prefix = "genai-cicd-dev"
  secrets = {
    docdb-creds = { description = "DB creds", secret_string = "..." }
  }
}
```

## Dependencies

None.
