# -----------------------------------------------------------------------------
# SNS Module — Outputs
# Exposes topic identifiers for consumption by other modules.
# -----------------------------------------------------------------------------

output "topic_arn" {
  description = "ARN of the SNS topic for pipeline notifications"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "topic_id" {
  description = "ID of the SNS topic"
  value       = aws_sns_topic.this.id
}
