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
|------|-------------|------|---------|----------|
| `name_prefix` | Naming prefix for resources | string | — | yes |
| `pipeline_names` | List of pipeline names to monitor | list(string) | — | yes |
| `sns_topic_arn` | ARN of the SNS topic for alarm notifications | string | — | yes |
| `failure_rate_alarm_threshold` | Pipeline failure rate percentage threshold for CloudWatch alarm | number | — | yes |
| `failure_rate_alarm_period` | Evaluation period in seconds for the failure rate alarm | number | — | yes |
| `aws_region` | AWS region for CloudWatch dashboard metrics | string | — | yes |
| `tags` | Tags to apply to all resources | map(string) | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `dashboard_name` | Name of the CloudWatch dashboard |
| `alarm_arns` | ARNs of the pipeline failure rate alarms |

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
