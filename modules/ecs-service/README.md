# Module: ecs-service

## Purpose

Creates an ECS Fargate task definition and service with rolling deployment, circuit breaker rollback, ALB integration, optional EFS volume mount, and secrets/environment injection.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Service and task family name | `string` | `n/a` | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image URI | `string` | `n/a` | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port | `number` | `8080` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate CPU units | `number` | `1024` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate memory (MiB) | `number` | `2048` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ECS task execution role ARN | `string` | `n/a` | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ECS task runtime role ARN | `string` | `n/a` | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets Manager references | `list(object)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment variables | `list(object)` | `[]` | no |
| <a name="input_efs_file_system_id"></a> [efs\_file\_system\_id](#input\_efs\_file\_system\_id) | EFS ID (empty to disable) | `string` | `""` | no |
| <a name="input_log_group"></a> [log\_group](#input\_log\_group) | CloudWatch log group name | `string` | `n/a` | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `n/a` | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ECS cluster ID | `string` | `n/a` | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | `n/a` | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs | `list(string)` | `n/a` | yes |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ALB target group ARN | `string` | `n/a` | yes |
| <a name="input_enable_circuit_breaker"></a> [enable\_circuit\_breaker](#input\_enable\_circuit\_breaker) | Enable circuit breaker | `bool` | `true` | no |
| <a name="input_enable_rollback"></a> [enable\_rollback](#input\_enable\_rollback) | Enable auto-rollback | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | ECS service name |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ECS service ID |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Task definition ARN |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | Task definition family |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | Task definition revision |

## Usage Example

```hcl
module "ecs_librechat" {
  source                 = "./modules/ecs-service"
  name                   = "genai-cicd-dev-librechat"
  container_image        = module.ecr_librechat.repository_url
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn
  cluster_id             = "my-cluster"
  subnet_ids             = ["subnet-abc"]
  security_group_ids     = ["sg-abc"]
  target_group_arn       = "arn:aws:elasticloadbalancing:..."
  log_group              = "/ecs/librechat-dev"
  aws_region             = "us-east-1"
}
```

## Dependencies

- `modules/iam` (provides role ARNs)
- `modules/ecr` (provides image URI)
- `modules/secrets` (provides secret ARNs for injection)
