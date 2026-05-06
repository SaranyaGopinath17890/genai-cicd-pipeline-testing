# GenAI CI/CD Pipeline — Terraform Infrastructure

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Modules](#modules)
- [Providers & Requirements](#providers--requirements)
- [Inputs](#inputs)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Deploying to a New Environment](#deploying-to-a-new-environment)
- [Module Dependencies](#module-dependencies)
- [Key Design Decisions](#key-design-decisions)

## Overview

This Terraform project provisions a CI/CD pipeline for the UMass GenAI environment:

- **LibreChat Pipeline** — builds and deploys the LibreChat GenAI application to ECS Fargate

Terraform is applied manually from a local machine for this POC. A dedicated Terraform pipeline and Admin Portal pipeline may be added in a future engagement.

All infrastructure is defined as reusable, parameterized Terraform modules supporting replication across up to 30 distinct AWS accounts.

## Architecture

```
GitHub → CodeConnection → CodePipeline → CodeBuild → ECR → ECS Fargate
                                                          ↓
                                              Circuit Breaker Rollback
                                                          ↓
                                                    SNS Notifications
```

## Modules

| Module | Description | README |
|--------|-------------|--------|
| [codebuild](./modules/codebuild/) | CodeBuild projects for Docker image builds | [README](./modules/codebuild/README.md) |
| [codepipeline](./modules/codepipeline/) | CodePipeline with Source, Build, Deploy stages and EventBridge notifications | [README](./modules/codepipeline/README.md) |
| [ecr](./modules/ecr/) | ECR repositories with scan-on-push and lifecycle policies | [README](./modules/ecr/README.md) |
| [ecs-service](./modules/ecs-service/) | ECS Fargate task definitions and services with circuit breaker rollback | [README](./modules/ecs-service/README.md) |
| [iam](./modules/iam/) | Least-privilege IAM roles for CodePipeline, CodeBuild, and ECS | [README](./modules/iam/README.md) |
| [secrets](./modules/secrets/) | Secrets Manager secrets and SSM Parameter Store parameters | [README](./modules/secrets/README.md) |
| [sns](./modules/sns/) | SNS topic and subscriptions for pipeline notifications | [README](./modules/sns/README.md) |
| [observability](./modules/observability/) | CloudWatch dashboard and alarms for pipeline metrics | — |
| [logging](./modules/logging/) | CloudWatch Log Groups for CodeBuild and ECS | — |

## Providers & Requirements

| Requirement | Version |
|-------------|---------|
| Terraform | >= 1.5 |
| AWS Provider | >= 5.0 |
| Provider Source | hashicorp/aws |

The root module configures the AWS provider with region and default tags. Child modules declare their own `required_providers` block but inherit the provider configuration from the root.

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, stage, prod) | `string` | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used in resource naming and tagging | `string` | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for deployment | `string` | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the environment | `string` | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for ECS tasks and CodeBuild | `list(string)` | yes |
| <a name="input_github_connection_name"></a> [github\_connection\_name](#input\_github\_connection\_name) | Name of the AWS CodeConnection for GitHub integration | `string` | yes |
| <a name="input_librechat_repo"></a> [librechat\_repo](#input\_librechat\_repo) | GitHub repository for LibreChat (owner/repo format) | `string` | yes |
| <a name="input_librechat_branch"></a> [librechat\_branch](#input\_librechat\_branch) | Branch pattern to trigger the LibreChat pipeline | `string` | yes |
| <a name="input_librechat_ecr_repository_name"></a> [librechat\_ecr\_repository\_name](#input\_librechat\_ecr\_repository\_name) | ECR repository name for LibreChat container images | `string` | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster (must already exist) | `string` | yes |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | ID of the ECS cluster (if different from name) | `string` | yes |
| <a name="input_librechat_container_port"></a> [librechat\_container\_port](#input\_librechat\_container\_port) | Container port for the LibreChat application | `number` | yes |
| <a name="input_librechat_cpu"></a> [librechat\_cpu](#input\_librechat\_cpu) | CPU units for the LibreChat ECS task | `number` | yes |
| <a name="input_librechat_memory"></a> [librechat\_memory](#input\_librechat\_memory) | Memory (MiB) for the LibreChat ECS task | `number` | yes |
| <a name="input_efs_file_system_id"></a> [efs\_file\_system\_id](#input\_efs\_file\_system\_id) | EFS file system ID for persistent storage | `string` | yes |
| <a name="input_docdb_cluster_endpoint"></a> [docdb\_cluster\_endpoint](#input\_docdb\_cluster\_endpoint) | DocumentDB cluster endpoint | `string` | yes |
| <a name="input_docdb_secret_arn"></a> [docdb\_secret\_arn](#input\_docdb\_secret\_arn) | Secrets Manager ARN for DocumentDB credentials | `string` | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket for application assets | `string` | yes |
| <a name="input_bedrock_model_id"></a> [bedrock\_model\_id](#input\_bedrock\_model\_id) | Amazon Bedrock model ID for GenAI capabilities | `string` | yes |
| <a name="input_notification_emails"></a> [notification\_emails](#input\_notification\_emails) | List of email addresses for SNS pipeline notifications | `list(string)` | yes |
| <a name="input_docker_build_context"></a> [docker\_build\_context](#input\_docker\_build\_context) | Docker build context path passed to CodeBuild | `string` | yes |
| <a name="input_codebuild_timeout_minutes"></a> [codebuild\_timeout\_minutes](#input\_codebuild\_timeout\_minutes) | Default timeout in minutes for application CodeBuild projects | `number` | yes |
| <a name="input_require_manual_approval"></a> [require\_manual\_approval](#input\_require\_manual\_approval) | Whether the pipeline requires manual approval before deploy | `bool` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs | `number` | yes |
| <a name="input_ecr_notification_type"></a> [ecr\_notification\_type](#input\_ecr\_notification\_type) | ECR notification scope: scan\_result, all, or none | `string` | yes |
| <a name="input_failure_rate_alarm_threshold"></a> [failure\_rate\_alarm\_threshold](#input\_failure\_rate\_alarm\_threshold) | Pipeline failure rate percentage threshold for CloudWatch alarm | `number` | yes |
| <a name="input_failure_rate_alarm_period"></a> [failure\_rate\_alarm\_period](#input\_failure\_rate\_alarm\_period) | Evaluation period in seconds for the failure rate alarm | `number` | yes |
| <a name="input_uma_speed_type"></a> [uma\_speed\_type](#input\_uma\_speed\_type) | UMass speed type tag value | `string` | yes |
| <a name="input_uma_function"></a> [uma\_function](#input\_uma\_function) | UMass function tag value | `string` | yes |
| <a name="input_uma_creator"></a> [uma\_creator](#input\_uma\_creator) | UMass creator tag value | `string` | yes |
| <a name="input_tag_arch"></a> [tag\_arch](#input\_tag\_arch) | ARCH tag value | `string` | yes |
| <a name="input_tag_env"></a> [tag\_env](#input\_tag\_env) | ENV tag value | `string` | yes |
| <a name="input_tag_org"></a> [tag\_org](#input\_tag\_org) | ORG tag value | `string` | yes |
| <a name="input_tag_project"></a> [tag\_project](#input\_tag\_project) | PROJECT tag value | `string` | yes |
| <a name="input_ecs_security_group_ids"></a> [ecs\_security\_group\_ids](#input\_ecs\_security\_group\_ids) | Security group IDs for ECS tasks | `list(string)` | yes |
| <a name="input_codebuild_security_group_ids"></a> [codebuild\_security\_group\_ids](#input\_codebuild\_security\_group\_ids) | Security group IDs for CodeBuild projects (if VPC access needed) | `list(string)` | yes |
| <a name="input_librechat_target_group_arn"></a> [librechat\_target\_group\_arn](#input\_librechat\_target\_group\_arn) | ARN of the ALB target group for LibreChat | `string` | yes |

## Project Structure

```
├── main.tf                    # Root composition — wires all modules together
├── variables.tf               # All environment-specific inputs
├── outputs.tf                 # Key resource identifiers
├── locals.tf                  # Naming conventions and common tags
├── backend.tf                 # S3 state backend with DynamoDB locking
├── versions.tf                # Terraform and provider version constraints
├── providers.tf               # AWS provider configuration with default tags
├── terraform.tfvars           # Dev environment values (REPLACE_ME placeholders)
├── buildspecs/
│   └── app-buildspec.yml      # Docker image build for LibreChat
├── environments/
│   └── dev/
│       └── terraform.tfvars   # Dev environment values
└── modules/
    ├── iam/            # IAM roles for CodePipeline, CodeBuild, ECS
    ├── ecr/            # ECR repositories with lifecycle policies
    ├── sns/            # SNS topic and subscriptions for notifications
    ├── secrets/        # Secrets Manager and Parameter Store entries
    ├── codebuild/      # CodeBuild projects (app builds)
    ├── codepipeline/   # CodePipeline with Source, Build, Deploy stages
    ├── ecs-service/    # ECS task definitions and services with circuit breaker
    ├── observability/  # CloudWatch dashboard and alarms
    └── logging/        # CloudWatch Log Groups
```

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured with appropriate credentials
- Existing infrastructure: VPC, subnets, ECS cluster, ALB with target groups, EFS, DocumentDB, S3 bucket
- GitHub repository for LibreChat

## Deploying to a New Environment

### Step 1: Copy the tfvars template

```bash
cp environments/dev/terraform.tfvars environments/<env>/terraform.tfvars
```

### Step 2: Update environment values

Edit `terraform.tfvars` and replace all `REPLACE_ME` placeholders:

| Variable | Description |
|----------|-------------|
| <a name="var_environment"></a> [environment](#var\_environment) | Environment name (e.g., `stage`, `prod`) |
| <a name="var_vpc_id"></a> [vpc\_id](#var\_vpc\_id) | VPC ID for the target environment |
| <a name="var_subnet_ids"></a> [subnet\_ids](#var\_subnet\_ids) | Private subnet IDs for ECS tasks and CodeBuild |
| <a name="var_librechat_repo"></a> [librechat\_repo](#var\_librechat\_repo) | GitHub repository (owner/repo format) |
| <a name="var_ecs_cluster_name"></a> [ecs\_cluster\_name](#var\_ecs\_cluster\_name) | Existing ECS cluster name |
| <a name="var_efs_file_system_id"></a> [efs\_file\_system\_id](#var\_efs\_file\_system\_id) | EFS file system ID |
| <a name="var_docdb_cluster_endpoint"></a> [docdb\_cluster\_endpoint](#var\_docdb\_cluster\_endpoint) | DocumentDB cluster endpoint |
| <a name="var_docdb_secret_arn"></a> [docdb\_secret\_arn](#var\_docdb\_secret\_arn) | Secrets Manager ARN for DB credentials |
| <a name="var_s3_bucket_name"></a> [s3\_bucket\_name](#var\_s3\_bucket\_name) | Application data S3 bucket |
| <a name="var_bedrock_model_id"></a> [bedrock\_model\_id](#var\_bedrock\_model\_id) | Amazon Bedrock model ID |
| <a name="var_notification_emails"></a> [notification\_emails](#var\_notification\_emails) | List of emails for SNS notifications |
| <a name="var_ecs_security_group_ids"></a> [ecs\_security\_group\_ids](#var\_ecs\_security\_group\_ids) | Security group IDs for ECS tasks |
| <a name="var_librechat_target_group_arn"></a> [librechat\_target\_group\_arn](#var\_librechat\_target\_group\_arn) | ALB target group ARN for LibreChat |

### Step 3: Update backend configuration

Edit `backend.tf` to use a unique state key for the new environment:

```hcl
backend "s3" {
  bucket         = "your-state-bucket"
  key            = "genai-cicd/<env>/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "your-lock-table"
  encrypt        = true
}
```

### Step 4: Initialize and apply

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Step 5: Confirm the CodeConnection

After `terraform apply`, the GitHub CodeConnection will be in PENDING status. Confirm it manually:

1. Go to **AWS Console → Developer Tools → Settings → Connections**
2. Select the connection
3. Click **Update pending connection** and authorize with GitHub

## Module Dependencies

```
iam ──────────────┐
                  ├──→ codebuild ──→ codepipeline
sns ──────────────┤                      ↑
secrets ──────────┤                      │
ecr ──────────────┤                      │
codeconnection ───┘                      │
                                         │
ecs-service ─────────────────────────────┘
```

## Key Design Decisions

- **Rolling deployment with ECS circuit breaker** — simpler than blue/green for POC; automatic rollback on failure
- **Single pipeline (LibreChat)** — scoped to one application for POC; Admin Portal and Terraform pipelines may be added in future engagements
- **Terraform applied locally** — no Terraform pipeline in AWS for this POC; reduces complexity and cost
- **Provider-level default_tags** — UMass mandatory tags applied to all resources automatically
- **Secrets Manager + Parameter Store** — no secrets in source code or S3
- **Reusable modules** — module directories retained for future use (Admin Portal, Terraform pipeline, drift detection)


