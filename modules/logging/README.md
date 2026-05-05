# Module: logging

## Purpose

Creates centralized CloudWatch Log Groups for CodeBuild and ECS components with configurable retention policies.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Naming prefix for resources | string | — | yes |
| `log_retention_days` | Number of days to retain CloudWatch logs | number | — | yes |
| `log_group_names` | Map of logical name to CloudWatch Log Group path | map(string) | — | yes |
| `tags` | Tags to apply to all log groups | map(string) | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `log_group_arns` | Map of logical name to CloudWatch Log Group ARN |
| `log_group_names` | Map of logical name to CloudWatch Log Group name |

## Usage Example

```hcl
module "logging" {
  source             = "./modules/logging"
  name_prefix        = "genai-cicd-dev"
  log_retention_days = 30
  log_group_names = {
    codebuild = "/codebuild/genai-cicd-dev"
    ecs       = "/ecs/genai-cicd-dev"
  }
  tags = { Environment = "dev" }
}
```

## Dependencies

None.
