# Module: ecs-service

## Purpose

Creates an ECS Fargate task definition and service with rolling deployment, circuit breaker rollback, ALB integration, optional EFS volume mount, and secrets/environment injection.

## Resources

- [`aws_ecs_service`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)
- [`aws_ecs_task_definition`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Service and task family name | string | — | yes |
| `container_image` | Docker image URI | string | — | yes |
| `container_port` | Container port | number | 8080 | no |
| `cpu` | Fargate CPU units | number | 1024 | no |
| `memory` | Fargate memory (MiB) | number | 2048 | no |
| `task_execution_role_arn` | ECS task execution role ARN | string | — | yes |
| `task_role_arn` | ECS task runtime role ARN | string | — | yes |
| `secrets` | Secrets Manager references | list(object) | [] | no |
| `environment` | Environment variables | list(object) | [] | no |
| `efs_file_system_id` | EFS ID (empty to disable) | string | "" | no |
| `log_group` | CloudWatch log group name | string | — | yes |
| `aws_region` | AWS region | string | — | yes |
| `cluster_id` | ECS cluster ID | string | — | yes |
| `subnet_ids` | Subnet IDs | list(string) | — | yes |
| `security_group_ids` | Security group IDs | list(string) | — | yes |
| `target_group_arn` | ALB target group ARN | string | — | yes |
| `enable_circuit_breaker` | Enable circuit breaker | bool | true | no |
| `enable_rollback` | Enable auto-rollback | bool | true | no |
| `tags` | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `service_name` | ECS service name |
| `service_id` | ECS service ID |
| `task_definition_arn` | Task definition ARN |
| `task_definition_family` | Task definition family |
| `task_definition_revision` | Task definition revision |

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

## Resources / References

- [Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [aws_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)
- [aws_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)
