# Module: logging

## Purpose

Creates centralized CloudWatch Log Groups for CodeBuild and ECS components with configurable retention policies.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for resources | `string` | `n/a` | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs | `number` | `n/a` | yes |
| <a name="input_log_group_names"></a> [log\_group\_names](#input\_log\_group\_names) | Map of logical name to CloudWatch Log Group path | `map(string)` | `n/a` | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all log groups | `map(string)` | `n/a` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_group_arns"></a> [log\_group\_arns](#output\_log\_group\_arns) | Map of logical name to CloudWatch Log Group ARN |
| <a name="output_log_group_names"></a> [log\_group\_names](#output\_log\_group\_names) | Map of logical name to CloudWatch Log Group name |

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
