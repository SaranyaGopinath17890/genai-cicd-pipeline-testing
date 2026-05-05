# Module: ecr

## Purpose

Creates an Amazon ECR repository with scan-on-push and lifecycle policies for image retention.

## Resources

- [`aws_ecr_repository`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)
- [`aws_ecr_lifecycle_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy)
- [`aws_cloudwatch_event_rule`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)
- [`aws_cloudwatch_event_target`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | ECR repository name | string | — | yes |
| `image_tag_mutability` | Tag mutability (MUTABLE/IMMUTABLE) | string | MUTABLE | no |
| `scan_on_push` | Enable vulnerability scanning on push | bool | true | no |
| `max_tagged_image_count` | Max tagged images to retain | number | 10 | no |
| `tagged_prefix_list` | Tag prefixes for retention rule | list(string) | ["dev","stage"] | no |
| `untagged_image_expiry_days` | Days before untagged images expire | number | 7 | no |
| `force_delete` | Delete repo even with images | bool | false | no |
| `tags` | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `repository_url` | ECR repository URL |
| `repository_arn` | ECR repository ARN |
| `repository_name` | ECR repository name |
| `registry_id` | AWS account ID hosting the registry |

## Usage Example

```hcl
module "ecr_librechat" {
  source = "./modules/ecr"
  name   = "genai-cicd-dev-librechat"
  tags   = { Environment = "dev" }
}
```

## Dependencies

None.

## Resources / References

- [Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [aws_ecr_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)
- [aws_ecr_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy)
