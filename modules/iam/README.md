# Module: iam

## Purpose

Creates least-privilege IAM roles for all pipeline components: CodePipeline, CodeBuild (application and Terraform), ECS task execution, ECS task runtime, and a dedicated Terraform execution role for AssumeRole-based access.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role.codebuild_terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild_terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role.terraform_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.terraform_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for all IAM resources | `string` | `n/a` | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all IAM resources | `map(string)` | `{}` | no |
| <a name="input_s3_artifact_bucket_arn"></a> [s3\_artifact\_bucket\_arn](#input\_s3\_artifact\_bucket\_arn) | ARN of the S3 artifact bucket | `string` | `""` | no |
| <a name="input_ecr_repository_arns"></a> [ecr\_repository\_arns](#input\_ecr\_repository\_arns) | List of ECR repository ARNs | `list(string)` | `[]` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic | `string` | `""` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of the ECS cluster | `string` | `""` | no |
| <a name="input_codebuild_project_arns"></a> [codebuild\_project\_arns](#input\_codebuild\_project\_arns) | List of CodeBuild project ARNs | `list(string)` | `[]` | no |
| <a name="input_secrets_manager_arns"></a> [secrets\_manager\_arns](#input\_secrets\_manager\_arns) | List of Secrets Manager ARNs | `list(string)` | `[]` | no |
| <a name="input_ssm_parameter_arns"></a> [ssm\_parameter\_arns](#input\_ssm\_parameter\_arns) | List of SSM Parameter ARNs | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_log_group_arns"></a> [cloudwatch\_log\_group\_arns](#input\_cloudwatch\_log\_group\_arns) | List of CloudWatch log group ARNs | `list(string)` | `[]` | no |
| <a name="input_efs_file_system_arn"></a> [efs\_file\_system\_arn](#input\_efs\_file\_system\_arn) | ARN of the EFS file system | `string` | `""` | no |
| <a name="input_s3_data_bucket_arn"></a> [s3\_data\_bucket\_arn](#input\_s3\_data\_bucket\_arn) | ARN of the application data S3 bucket | `string` | `""` | no |
| <a name="input_terraform_state_bucket_arn"></a> [terraform\_state\_bucket\_arn](#input\_terraform\_state\_bucket\_arn) | ARN of the Terraform state S3 bucket | `string` | `""` | no |
| <a name="input_terraform_lock_table_arn"></a> [terraform\_lock\_table\_arn](#input\_terraform\_lock\_table\_arn) | ARN of the DynamoDB lock table | `string` | `""` | no |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | ARN of the CodeConnection | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_role_arn"></a> [codepipeline\_role\_arn](#output\_codepipeline\_role\_arn) | ARN of the CodePipeline service role |
| <a name="output_codebuild_role_arn"></a> [codebuild\_role\_arn](#output\_codebuild\_role\_arn) | ARN of the CodeBuild role (app builds) |
| <a name="output_codebuild_terraform_role_arn"></a> [codebuild\_terraform\_role\_arn](#output\_codebuild\_terraform\_role\_arn) | ARN of the CodeBuild role (Terraform) |
| <a name="output_ecs_task_execution_role_arn"></a> [ecs\_task\_execution\_role\_arn](#output\_ecs\_task\_execution\_role\_arn) | ARN of the ECS task execution role |
| <a name="output_ecs_task_role_arn"></a> [ecs\_task\_role\_arn](#output\_ecs\_task\_role\_arn) | ARN of the ECS task runtime role |
| <a name="output_terraform_execution_role_arn"></a> [terraform\_execution\_role\_arn](#output\_terraform\_execution\_role\_arn) | ARN of the Terraform execution role |

## Usage Example

```hcl
module "iam" {
  source      = "./modules/iam"
  name_prefix = "genai-cicd-dev"
  tags        = { Environment = "dev" }
}
```

## Dependencies

None (foundational module).
