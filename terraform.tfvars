# -----------------------------------------------------------------------------
# Dev environment values for GenAI CI/CD Pipeline — Sandbox Testing
#
# This uses the CDW sandbox account (429247474025) for hello world testing.
# Replace with customer values when deploying to UMass.
# -----------------------------------------------------------------------------

# General
environment  = "dev"
project_name = "genai-cicd"
aws_region   = "us-east-1"

# Networking (default VPC in sandbox)
vpc_id     = "vpc-64a01519"
subnet_ids = ["subnet-07b8cd54a81377335", "subnet-0bf0aeba21b297331"]

# GitHub / Source
github_connection_name = "github-connection"
librechat_repo         = "SaranyaGopinath17890/genai-cicd-pipeline-testing"
librechat_branch       = "main"

# ECR
librechat_ecr_repository_name = "librechat"

# ECS / Compute
librechat_container_port = 80 # nginx listens on 80
librechat_cpu            = 256
librechat_memory         = 512

# Data & Storage (dummy values — not used by hello world nginx app)
efs_file_system_id     = ""
docdb_cluster_endpoint = "placeholder"
docdb_secret_arn       = "placeholder"
s3_bucket_name         = "umass-state-bucket-test"

# GenAI (not used by hello world app)
bedrock_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"

# Notifications
notification_email = "saranya.gopinath@cdwg.com"

# Docker build context
docker_build_context = "apps/librechat"

# -----------------------------------------------
# Tags
# -----------------------------------------------

# UMass Mandatory Tags (test values for sandbox)
uma_speed_type = "test"
uma_function   = "cicd-poc"
uma_creator    = "cdw"

# Project Tags
tag_arch    = "scalable"
tag_env     = "dev"
tag_org     = "umass"
tag_project = "genai"

# Pipeline behavior
require_manual_approval      = true
codebuild_timeout_minutes    = 30
codebuild_security_group_ids = []

# Logging
log_retention_days = 30

# ECR Scanning
ecr_notification_type = "scan_result"

# Observability
failure_rate_alarm_threshold = 50
failure_rate_alarm_period    = 3600

# ECS (created by test-infra.tf — these are unused but required)
ecs_cluster_name          = "gen-ai-cicd-cluster"
ecs_security_group_ids    = []
ecs_cluster_id            = ""
librechat_target_group_arn = ""
