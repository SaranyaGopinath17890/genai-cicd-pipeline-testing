# -----------------------------------------------------------------------------
# Pipeline Observability
# CloudWatch Dashboard and failure rate alarms for all three pipelines.
#
# Requirements: 15.2, 15.3
# -----------------------------------------------------------------------------

variable "failure_rate_alarm_threshold" {
  description = "Pipeline failure rate percentage threshold for CloudWatch alarm"
  type        = number
  default     = 50
}

variable "failure_rate_alarm_period" {
  description = "Evaluation period in seconds for the failure rate alarm"
  type        = number
  default     = 3600
}

# =============================================================================
# CloudWatch Dashboard
# =============================================================================

resource "aws_cloudwatch_dashboard" "pipelines" {
  dashboard_name = "${local.name_prefix}-pipelines"

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
          metrics = [
            ["AWS/CodePipeline", "PipelineExecutionSucceeded", "PipelineName", module.pipeline_librechat.pipeline_name, { stat = "Sum", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionSucceeded", "PipelineName", module.pipeline_admin_portal.pipeline_name, { stat = "Sum", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionSucceeded", "PipelineName", module.pipeline_terraform.pipeline_name, { stat = "Sum", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", module.pipeline_librechat.pipeline_name, { stat = "Sum", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", module.pipeline_admin_portal.pipeline_name, { stat = "Sum", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", module.pipeline_terraform.pipeline_name, { stat = "Sum", period = 86400 }],
          ]
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
            ["AWS/CodePipeline", "PipelineExecutionTime", "PipelineName", module.pipeline_librechat.pipeline_name, { stat = "Average", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionTime", "PipelineName", module.pipeline_admin_portal.pipeline_name, { stat = "Average", period = 86400 }],
            ["AWS/CodePipeline", "PipelineExecutionTime", "PipelineName", module.pipeline_terraform.pipeline_name, { stat = "Average", period = 86400 }],
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
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", module.pipeline_librechat.pipeline_name, { stat = "Sum", period = 3600, color = "#d62728" }],
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", module.pipeline_admin_portal.pipeline_name, { stat = "Sum", period = 3600, color = "#ff7f0e" }],
            ["AWS/CodePipeline", "PipelineExecutionFailed", "PipelineName", module.pipeline_terraform.pipeline_name, { stat = "Sum", period = 3600, color = "#9467bd" }],
          ]
          region = var.aws_region
          period = 3600
        }
      }
    ]
  })
}

# =============================================================================
# CloudWatch Alarm — Pipeline Failure Rate
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "pipeline_failure_librechat" {
  alarm_name          = "${local.librechat_name}-pipeline-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.failure_rate_alarm_threshold
  alarm_description   = "LibreChat pipeline failure rate exceeds ${var.failure_rate_alarm_threshold}%"
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
        PipelineName = module.pipeline_librechat.pipeline_name
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
        PipelineName = module.pipeline_librechat.pipeline_name
      }
    }
  }

  alarm_actions = [module.sns.topic_arn]
  tags          = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "pipeline_failure_admin_portal" {
  alarm_name          = "${local.admin_portal_name}-pipeline-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.failure_rate_alarm_threshold
  alarm_description   = "Admin Portal pipeline failure rate exceeds ${var.failure_rate_alarm_threshold}%"
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
        PipelineName = module.pipeline_admin_portal.pipeline_name
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
        PipelineName = module.pipeline_admin_portal.pipeline_name
      }
    }
  }

  alarm_actions = [module.sns.topic_arn]
  tags          = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "pipeline_failure_terraform" {
  alarm_name          = "${local.terraform_name}-pipeline-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.failure_rate_alarm_threshold
  alarm_description   = "Terraform pipeline failure rate exceeds ${var.failure_rate_alarm_threshold}%"
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
        PipelineName = module.pipeline_terraform.pipeline_name
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
        PipelineName = module.pipeline_terraform.pipeline_name
      }
    }
  }

  alarm_actions = [module.sns.topic_arn]
  tags          = local.common_tags
}
