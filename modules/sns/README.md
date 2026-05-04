# Module: sns

## Purpose

Creates a shared SNS topic for pipeline notifications with email subscription and a topic policy allowing CodePipeline, EventBridge, CodeBuild, and AWS Budgets to publish.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | SNS topic name | string | — | yes |
| notification_email | Email for SNS subscription | string | — | yes |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| topic_arn | SNS topic ARN |
| topic_name | SNS topic name |
| topic_id | SNS topic ID |

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
