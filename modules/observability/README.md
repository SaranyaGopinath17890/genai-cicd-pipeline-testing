# Module: observability

## Purpose

Creates a CloudWatch Dashboard for pipeline metrics visualization and CloudWatch Metric Alarms for pipeline failure rate monitoring with SNS notifications.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.pipelines](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.pipeline_failure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for resources | `string` | `n/a` | yes |
| <a name="input_pipeline_names"></a> [pipeline\_names](#input\_pipeline\_names) | List of pipeline names to monitor | `list(string)` | `n/a` | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic for alarm notifications | `string` | `n/a` | yes |
| <a name="input_failure_rate_alarm_threshold"></a> [failure\_rate\_alarm\_threshold](#input\_failure\_rate\_alarm\_threshold) | Pipeline failure rate percentage threshold for CloudWatch alarm | `number` | `n/a` | yes |
| <a name="input_failure_rate_alarm_period"></a> [failure\_rate\_alarm\_period](#input\_failure\_rate\_alarm\_period) | Evaluation period in seconds for the failure rate alarm | `number` | `n/a` | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for CloudWatch dashboard metrics | `string` | `n/a` | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `n/a` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_name"></a> [dashboard\_name](#output\_dashboard\_name) | Name of the CloudWatch dashboard |
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | ARNs of the pipeline failure rate alarms |

## Usage Example

```hcl
module "observability" {
  source                       = "./modules/observability"
  name_prefix                  = "genai-cicd-dev"
  pipeline_names               = ["librechat-pipeline", "terraform-pipeline"]
  sns_topic_arn                = module.sns.topic_arn
  failure_rate_alarm_threshold = 50
  failure_rate_alarm_period    = 86400
  aws_region                   = "us-east-1"
  tags                         = { Environment = "dev" }
}
```

## Dependencies

- `modules/sns` (provides SNS topic ARN for alarm notifications)
