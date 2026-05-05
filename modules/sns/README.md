# Module: sns

## Purpose

Creates a shared SNS topic for pipeline notifications with email subscription and a topic policy allowing CodePipeline, EventBridge, CodeBuild, and AWS Budgets to publish.

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | SNS topic name | string | — | yes |
| `notification_email` | Email for SNS subscription | string | — | yes |
| `tags` | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `topic_arn` | SNS topic ARN |
| `topic_name` | SNS topic name |
| `topic_id` | SNS topic ID |

## Usage Example

```hcl
module "sns" {
  source             = "./modules/sns"
  name               = "genai-cicd-dev-notifications"
  notification_email = "team@umass.edu"
}
```

## Dependencies

None.
