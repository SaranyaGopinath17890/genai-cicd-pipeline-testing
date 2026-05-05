# Module: codepipeline

## Purpose

Creates an AWS CodePipeline with configurable stages. Supports two pipeline types: application (Source→Build→Deploy) and terraform (Source→Validate→Plan→[Approval]→Apply). Includes EventBridge notification rules for pipeline state changes.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_codepipeline.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_codepipeline.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_cloudwatch_event_rule.pipeline_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.pipeline_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Pipeline name | `string` | `n/a` | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | CodePipeline IAM role ARN | `string` | `n/a` | yes |
| <a name="input_artifact_bucket_name"></a> [artifact\_bucket\_name](#input\_artifact\_bucket\_name) | S3 bucket for artifacts | `string` | `n/a` | yes |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | CodeConnection ARN | `string` | `n/a` | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | GitHub repo (owner/repo) | `string` | `n/a` | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch to trigger on | `string` | `"dev"` | no |
| <a name="input_pipeline_type"></a> [pipeline\_type](#input\_pipeline\_type) | application or terraform | `string` | `"application"` | no |
| <a name="input_codebuild_project_name"></a> [codebuild\_project\_name](#input\_codebuild\_project\_name) | Build project name (app) | `string` | `n/a` | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS cluster name (app) | `string` | `n/a` | yes |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | ECS service name (app) | `string` | `n/a` | yes |
| <a name="input_terraform_plan_project_name"></a> [terraform\_plan\_project\_name](#input\_terraform\_plan\_project\_name) | Plan project (terraform) | `string` | `""` | no |
| <a name="input_terraform_apply_project_name"></a> [terraform\_apply\_project\_name](#input\_terraform\_apply\_project\_name) | Apply project (terraform) | `string` | `""` | no |
| <a name="input_terraform_validate_project_name"></a> [terraform\_validate\_project\_name](#input\_terraform\_validate\_project\_name) | Validate project (terraform) | `string` | `""` | no |
| <a name="input_require_manual_approval"></a> [require\_manual\_approval](#input\_require\_manual\_approval) | Include approval gate | `bool` | `false` | no |
| <a name="input_approval_sns_topic_arn"></a> [approval\_sns\_topic\_arn](#input\_approval\_sns\_topic\_arn) | SNS for approval notifications | `string` | `""` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | SNS for pipeline events | `string` | `""` | no |
| <a name="input_notification_events"></a> [notification\_events](#input\_notification\_events) | Event filter | `string` | `"both"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pipeline_arn"></a> [pipeline\_arn](#output\_pipeline\_arn) | CodePipeline ARN |
| <a name="output_pipeline_name"></a> [pipeline\_name](#output\_pipeline\_name) | CodePipeline name |
| <a name="output_artifact_bucket_name"></a> [artifact\_bucket\_name](#output\_artifact\_bucket\_name) | S3 artifact bucket name |
| <a name="output_artifact_bucket_arn"></a> [artifact\_bucket\_arn](#output\_artifact\_bucket\_arn) | S3 artifact bucket ARN |

## Usage Example

```hcl
module "pipeline_librechat" {
  source                  = "./modules/codepipeline"
  name                    = "genai-cicd-dev-librechat-pipeline"
  role_arn                = module.iam.codepipeline_role_arn
  artifact_bucket_name    = "genai-cicd-dev-librechat-artifacts"
  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = "umass/librechat"
  pipeline_type           = "application"
  codebuild_project_name  = module.codebuild_librechat.project_name
  ecs_cluster_name        = "my-cluster"
  ecs_service_name        = module.ecs_librechat.service_name
}
```

## Dependencies

- `modules/iam` (provides role ARN)
- `modules/codebuild` (provides project name)
- `modules/ecs-service` (provides service name, for app pipelines)
