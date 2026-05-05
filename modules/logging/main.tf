# -----------------------------------------------------------------------------
# Logging Module
# Centralized CloudWatch Log Groups for CodeBuild and ECS components.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_group_names

  name              = each.value
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
