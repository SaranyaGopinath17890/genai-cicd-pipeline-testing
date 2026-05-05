# Module: codepipeline

## Purpose

Creates an AWS CodePipeline with configurable stages. Supports two pipeline types: application (Source→Build→Deploy) and terraform (Source→Validate→Plan→[Approval]→Apply). Includes EventBridge notification rules for pipeline state changes.

## Resources

- [`aws_codepipeline`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline)
- [`aws_s3_bucket`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [`aws_cloudwatch_event_rule`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)
- [`aws_cloudwatch_event_target`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Pipeline name | string | — | yes |
| `role_arn` | CodePipeline IAM role ARN | string | — | yes |
| `artifact_bucket_name` | S3 bucket for artifacts | string | — | yes |
| `codestar_connection_arn` | CodeConnection ARN | string | — | yes |
| `repository` | GitHub repo (owner/repo) | string | — | yes |
| `branch` | Branch to trigger on | string | dev | no |
| `pipeline_type` | application or terraform | string | application | no |
| `codebuild_project_name` | Build project name (app) | string | — | yes (app) |
| `ecs_cluster_name` | ECS cluster name (app) | string | — | yes (app) |
| `ecs_service_name` | ECS service name (app) | string | — | yes (app) |
| `terraform_plan_project_name` | Plan project (terraform) | string | "" | no |
| `terraform_apply_project_name` | Apply project (terraform) | string | "" | no |
| `terraform_validate_project_name` | Validate project (terraform) | string | "" | no |
| `require_manual_approval` | Include approval gate | bool | false | no |
| `approval_sns_topic_arn` | SNS for approval notifications | string | "" | no |
| `sns_topic_arn` | SNS for pipeline events | string | "" | no |
| `notification_events` | Event filter | string | both | no |
| `tags` | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `pipeline_arn` | CodePipeline ARN |
| `pipeline_name` | CodePipeline name |
| `artifact_bucket_name` | S3 artifact bucket name |
| `artifact_bucket_arn` | S3 artifact bucket ARN |

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

## Resources / References

- [AWS CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
- [aws_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline)
- [aws_codestarnotifications_notification_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarnotifications_notification_rule)
