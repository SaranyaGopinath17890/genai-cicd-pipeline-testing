# Module: iam

## Purpose

Creates least-privilege IAM roles for all pipeline components: CodePipeline, CodeBuild (application and Terraform), ECS task execution, ECS task runtime, and a dedicated Terraform execution role for AssumeRole-based access.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Naming prefix for all IAM resources | string | — | yes |
| tags | Tags to apply to all IAM resources | map(string) | {} | no |
| s3_artifact_bucket_arn | ARN of the S3 artifact bucket | string | "" | no |
| ecr_repository_arns | List of ECR repository ARNs | list(string) | [] | no |
| sns_topic_arn | ARN of the SNS topic | string | "" | no |
| ecs_cluster_arn | ARN of the ECS cluster | string | "" | no |
| codebuild_project_arns | List of CodeBuild project ARNs | list(string) | [] | no |
| secrets_manager_arns | List of Secrets Manager ARNs | list(string) | [] | no |
| ssm_parameter_arns | List of SSM Parameter ARNs | list(string) | [] | no |
| cloudwatch_log_group_arns | List of CloudWatch log group ARNs | list(string) | [] | no |
| efs_file_system_arn | ARN of the EFS file system | string | "" | no |
| s3_data_bucket_arn | ARN of the application data S3 bucket | string | "" | no |
| terraform_state_bucket_arn | ARN of the Terraform state S3 bucket | string | "" | no |
| terraform_lock_table_arn | ARN of the DynamoDB lock table | string | "" | no |
| codestar_connection_arn | ARN of the CodeConnection | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| codepipeline_role_arn | ARN of the CodePipeline service role |
| codebuild_role_arn | ARN of the CodeBuild role (app builds) |
| codebuild_terraform_role_arn | ARN of the CodeBuild role (Terraform) |
| ecs_task_execution_role_arn | ARN of the ECS task execution role |
| ecs_task_role_arn | ARN of the ECS task runtime role |
| terraform_execution_role_arn | ARN of the Terraform execution role |

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
