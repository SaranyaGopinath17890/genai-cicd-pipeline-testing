# -----------------------------------------------------------------------------
# IAM Module — Outputs
# Exposes role ARNs and names for consumption by other modules.
# -----------------------------------------------------------------------------

# CodePipeline role
output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline service role"
  value       = aws_iam_role.codepipeline.arn
}

output "codepipeline_role_name" {
  description = "Name of the CodePipeline service role"
  value       = aws_iam_role.codepipeline.name
}

# CodeBuild role (application builds)
output "codebuild_role_arn" {
  description = "ARN of the CodeBuild service role for application builds"
  value       = aws_iam_role.codebuild.arn
}

output "codebuild_role_name" {
  description = "Name of the CodeBuild service role for application builds"
  value       = aws_iam_role.codebuild.name
}

# CodeBuild Terraform role
output "codebuild_terraform_role_arn" {
  description = "ARN of the CodeBuild service role for Terraform plan/apply"
  value       = aws_iam_role.codebuild_terraform.arn
}

output "codebuild_terraform_role_name" {
  description = "Name of the CodeBuild service role for Terraform plan/apply"
  value       = aws_iam_role.codebuild_terraform.name
}

# ECS task execution role
output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.name
}

# ECS task role (runtime)
output "ecs_task_role_arn" {
  description = "ARN of the ECS task role for runtime permissions"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role for runtime permissions"
  value       = aws_iam_role.ecs_task.name
}

# Terraform execution role (AssumeRole target)
output "terraform_execution_role_arn" {
  description = "ARN of the dedicated Terraform execution role (assumed via sts:AssumeRole)"
  value       = aws_iam_role.terraform_execution.arn
}

output "terraform_execution_role_name" {
  description = "Name of the dedicated Terraform execution role"
  value       = aws_iam_role.terraform_execution.name
}
