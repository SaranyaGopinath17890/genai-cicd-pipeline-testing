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
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for resources | `string` | `n/a` | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets (name → {description, secret_string}) | `map(object)` | `{}` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Map of parameters (name → {description, type, value}) | `map(object)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns) | Map of secret name → ARN |
| <a name="output_parameter_arns"></a> [parameter\_arns](#output\_parameter\_arns) | Map of parameter name → ARN |
| <a name="output_all_secret_arns"></a> [all\_secret\_arns](#output\_all\_secret\_arns) | Flat list of all secret ARNs |
| <a name="output_all_parameter_arns"></a> [all\_parameter\_arns](#output\_all\_parameter\_arns) | Flat list of all parameter ARNs |

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
