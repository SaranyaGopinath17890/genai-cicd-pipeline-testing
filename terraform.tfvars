# -----------------------------------------------------------------------------
# Dev environment values for GenAI CI/CD Pipeline
#
# Replace all "REPLACE_ME" placeholders with actual account-specific values
# before running terraform plan / apply.
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
librechat_repo         = "REPLACE_ME" # e.g., "umass-amherst/librechat"
librechat_branch       = "dev*"

# ECR
librechat_ecr_repository_name = "librechat"

# ECS / Compute
ecs_cluster_name         = "REPLACE_ME"
ecs_cluster_id           = "" # Leave empty to use ecs_cluster_name
librechat_container_port = 8080
librechat_cpu            = 1024
librechat_memory         = 2048

# Data & Storage
efs_file_system_id     = "REPLACE_ME"
docdb_cluster_endpoint = "REPLACE_ME"
docdb_secret_arn       = "REPLACE_ME" # e.g., "arn:aws:secretsmanager:us-east-1:123456789012:secret:docdb-creds"
s3_bucket_name         = "REPLACE_ME"

# GenAI
bedrock_model_id = "REPLACE_ME" # e.g., "anthropic.claude-3-sonnet-20240229-v1:0"

# Notifications
notification_email = "REPLACE_ME" # e.g., "team@umass.edu"

# Security Groups
ecs_security_group_ids       = ["REPLACE_ME"]
codebuild_security_group_ids = [] # Only needed if CodeBuild requires VPC access

# Load Balancer
librechat_target_group_arn = "REPLACE_ME"

# -----------------------------------------------
# Tags
# All resource tags are defined here and applied via default_tags in providers.tf.
# -----------------------------------------------

# UMass Mandatory Tags
uma_speed_type = "REPLACE_ME"
uma_function   = "REPLACE_ME"
uma_creator    = "REPLACE_ME"

# Project Tags
tag_arch    = "scalable"
tag_env     = "dev"
tag_org     = "umass"
tag_project = "genai"
