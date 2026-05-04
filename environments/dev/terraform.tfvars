# -----------------------------------------------------------------------------
# Dev environment values for GenAI CI/CD Pipeline
#
# Replace all "REPLACE_ME" placeholders with actual account-specific values
# before running terraform plan / apply.
#
# To replicate to a new environment:
#   1. Copy this file to environments/<env>/terraform.tfvars
#   2. Update the values below for the target AWS account and environment
#   3. Update backend.tf with a new state key for the environment
#   4. Run: terraform init && terraform plan -var-file=environments/<env>/terraform.tfvars
# -----------------------------------------------------------------------------

# General
environment  = "dev"
project_name = "genai-cicd"
aws_region   = "us-east-1"

# Networking
vpc_id     = "REPLACE_ME"
subnet_ids = ["REPLACE_ME", "REPLACE_ME"]

# GitHub / Source
github_connection_name = "github-connection"
librechat_repo         = "REPLACE_ME"   # e.g., "umass-amherst/librechat"
librechat_branch       = "dev*"
admin_portal_repo      = "REPLACE_ME"   # e.g., "umass-amherst/admin-portal"
admin_portal_branch    = "dev*"
terraform_repo         = "REPLACE_ME"   # e.g., "umass-amherst/terraform-cicd"
terraform_branch       = "dev"

# ECR
librechat_ecr_repository_name    = "librechat"
admin_portal_ecr_repository_name = "admin-portal"

# ECS / Compute
ecs_cluster_name            = "REPLACE_ME"
librechat_container_port    = 8080
admin_portal_container_port = 8080
librechat_cpu               = 1024
librechat_memory            = 2048
admin_portal_cpu            = 1024
admin_portal_memory         = 2048

# Data & Storage
efs_file_system_id     = "REPLACE_ME"
docdb_cluster_endpoint = "REPLACE_ME"
docdb_secret_arn       = "REPLACE_ME"   # e.g., "arn:aws:secretsmanager:us-east-1:123456789012:secret:docdb-creds"
s3_bucket_name         = "REPLACE_ME"

# GenAI
bedrock_model_id = "REPLACE_ME"   # e.g., "anthropic.claude-3-sonnet-20240229-v1:0"

# Notifications
notification_email = "REPLACE_ME"   # e.g., "team@umass.edu"

# Pipeline behavior
require_manual_approval = false   # Set to true for prod environments

# UMass Mandatory Tags
uma_speed_type = "REPLACE_ME"
uma_function   = "REPLACE_ME"
uma_creator    = "REPLACE_ME"
tag_arch       = "scalable"
tag_org        = "umass"
tag_project    = "genai"

# Security Groups
ecs_security_group_ids      = ["REPLACE_ME"]
codebuild_security_group_ids = []   # Only needed if CodeBuild requires VPC access

# Load Balancer
librechat_target_group_arn    = "REPLACE_ME"
admin_portal_target_group_arn = "REPLACE_ME"

# ECS Cluster
ecs_cluster_id = ""   # Leave empty to use ecs_cluster_name

# Additional tags (optional)
additional_tags = {
  Owner      = "UMass"
  CostCenter = "REPLACE_ME"
}
