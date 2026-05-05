# -----------------------------------------------------------------------------
# Observability Module — Outputs
# -----------------------------------------------------------------------------

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.pipelines.dashboard_name
}

output "alarm_arns" {
  description = "ARNs of the pipeline failure rate alarms"
  value       = [for alarm in aws_cloudwatch_metric_alarm.pipeline_failure : alarm.arn]
}
