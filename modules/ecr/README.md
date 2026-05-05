# Module: ecr

## Purpose

Creates an Amazon ECR repository with scan-on-push and lifecycle policies for image retention.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_cloudwatch_event_rule.ecr_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ecr_scan_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | ECR repository name | `string` | `n/a` | yes |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | Tag mutability (MUTABLE/IMMUTABLE) | `string` | `"MUTABLE"` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Enable vulnerability scanning on push | `bool` | `true` | no |
| <a name="input_max_tagged_image_count"></a> [max\_tagged\_image\_count](#input\_max\_tagged\_image\_count) | Max tagged images to retain | `number` | `10` | no |
| <a name="input_tagged_prefix_list"></a> [tagged\_prefix\_list](#input\_tagged\_prefix\_list) | Tag prefixes for retention rule | `list(string)` | `["dev","stage"]` | no |
| <a name="input_untagged_image_expiry_days"></a> [untagged\_image\_expiry\_days](#input\_untagged\_image\_expiry\_days) | Days before untagged images expire | `number` | `7` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Delete repo even with images | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | ECR repository URL |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ECR repository ARN |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | ECR repository name |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | AWS account ID hosting the registry |

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
