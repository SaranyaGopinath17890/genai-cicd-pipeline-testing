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
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | SNS topic name | `string` | `n/a` | yes |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email for SNS subscription | `string` | `n/a` | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_topic_arn"></a> [topic\_arn](#output\_topic\_arn) | SNS topic ARN |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | SNS topic name |
| <a name="output_topic_id"></a> [topic\_id](#output\_topic\_id) | SNS topic ID |

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
