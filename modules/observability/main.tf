# -----------------------------------------------------------------------------
# Observability Module
# CloudWatch Dashboard and failure rate alarms for pipelines.
# -----------------------------------------------------------------------------

# =============================================================================
# CloudWatch Dashboard
# =============================================================================

resource "aws_cloudwatch_dashboard" "pipelines" {
  dashboard_name = "${var.name_prefix}-pipelines"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Pipeline Execution Count"
          view    = "timeSeries"
          stacked = false
          metrics = flatten([
            for name in var.pipeline_names : [
              ["AWS/CodePipeline", "PipelineExecutionSucceeded", "PipelineName", name, { stat = "Sum", period = 86400 }],
              ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", name, { stat = "Sum", period = 86400 }],
            ]
          ])
          region = var.aws_region
          period = 86400
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Pipeline Execution Duration (avg)"
          view    = "timeSeries"
          stacked = false
          metrics = [
            for name in var.pipeline_names :
            ["AWS/CodePipeline", "PipelineExecutionTime", "PipelineName", name, { stat = "Average", period = 86400 }]
          ]
          region = var.aws_region
          period = 86400
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title   = "Pipeline Failures"
          view    = "timeSeries"
          stacked = true
          metrics = [
            for name in var.pipeline_names :
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", name, { stat = "Sum", period = 3600 }]
          ]
          region = var.aws_region
          period = 3600
        }
      }
    ]
  })
}

# =============================================================================
# CloudWatch Alarms — Pipeline Failure Rate
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "pipeline_failure" {
  count = length(var.pipeline_names)

  alarm_name          = "${var.pipeline_names[count.index]}-pipeline-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.failure_rate_alarm_threshold
  alarm_description   = "${var.pipeline_names[count.index]} pipeline failure rate exceeds ${var.failure_rate_alarm_threshold}%"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "failure_rate"
    expression  = "IF(total > 0, (failures / total) * 100, 0)"
    label       = "Failure Rate %"
    return_data = true
  }

  metric_query {
    id = "failures"
    metric {
      metric_name = "PipelineExecutionFailed"
      namespace   = "AWS/CodePipeline"
      period      = var.failure_rate_alarm_period
      stat        = "Sum"
      dimensions = {
        PipelineName = var.pipeline_names[count.index]
      }
    }
  }

  metric_query {
    id = "total"
    metric {
      metric_name = "PipelineExecutionStarted"
      namespace   = "AWS/CodePipeline"
      period      = var.failure_rate_alarm_period
      stat        = "Sum"
      dimensions = {
        PipelineName = var.pipeline_names[count.index]
      }
    }
  }

  alarm_actions = [var.sns_topic_arn]
  tags          = var.tags
}
