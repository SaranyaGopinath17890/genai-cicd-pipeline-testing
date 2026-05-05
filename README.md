# GenAI CI/CD Pipeline — Terraform Infrastructure

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Modules](#modules)
- [Providers & Requirements](#providers--requirements)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Deploying to a New Environment](#deploying-to-a-new-environment)
- [Module Dependencies](#module-dependencies)
- [Key Design Decisions](#key-design-decisions)
- [Resources / References](#resources--references)

## Overview

This Terraform project provisions three CI/CD pipelines for the UMass GenAI environment:

1. **LibreChat Pipeline** — builds and deploys the LibreChat GenAI application to ECS Fargate
2. **Admin Portal Pipeline** — builds and deploys the administration portal to ECS Fargate
3. **Terraform Pipeline** — runs terraform plan/apply with optional manual approval

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
| [codebuild](./modules/codebuild/) | CodeBuild projects for Docker image builds and Terraform operations | [README](./modules/codebuild/README.md) |
| [codepipeline](./modules/codepipeline/) | CodePipeline with Source, Build, Deploy stages and EventBridge notifications | [README](./modules/codepipeline/README.md) |
| [ecr](./modules/ecr/) | ECR repositories with scan-on-push and lifecycle policies | [README](./modules/ecr/README.md) |
| [ecs-service](./modules/ecs-service/) | ECS Fargate task definitions and services with circuit breaker rollback | [README](./modules/ecs-service/README.md) |
| [iam](./modules/iam/) | Least-privilege IAM roles for CodePipeline, CodeBuild, and ECS | [README](./modules/iam/README.md) |
| [secrets](./modules/secrets/) | Secrets Manager secrets and SSM Parameter Store parameters | [README](./modules/secrets/README.md) |
| [sns](./modules/sns/) | SNS topic and subscriptions for pipeline notifications | [README](./modules/sns/README.md) |

## Providers & Requirements

| Requirement | Version |
|-------------|---------|
| Terraform | >= 1.5 |
| AWS Provider | >= 5.0 |
| Provider Source | hashicorp/aws |

The root module configures the AWS provider with region and default tags. Child modules declare their own `required_providers` block but inherit the provider configuration from the root.

## Project Structure

```
├── main.tf                    # Root composition — wires all modules together
├── variables.tf               # All environment-specific inputs
├── outputs.tf                 # Key resource identifiers
├── locals.tf                  # Naming conventions and common tags
├── backend.tf                 # S3 state backend with DynamoDB locking
├── versions.tf                # Terraform and provider version constraints
├── providers.tf               # AWS provider configuration with default tags
├── codeconnection.tf          # GitHub CodeConnection resource
├── logging.tf                 # CloudWatch Log Groups
├── buildspecs/
│   ├── app-buildspec.yml              # Docker image build for applications
│   ├── terraform-plan-buildspec.yml   # Terraform plan
│   └── terraform-apply-buildspec.yml  # Terraform apply
├── environments/
│   └── dev/
│       └── terraform.tfvars   # Dev environment values (REPLACE_ME placeholders)
└── modules/
    ├── iam/            # IAM roles for CodePipeline, CodeBuild, ECS
    ├── ecr/            # ECR repositories with lifecycle policies
    ├── sns/            # SNS topic and subscriptions for notifications
    ├── secrets/        # Secrets Manager and Parameter Store entries
    ├── codebuild/      # CodeBuild projects (app builds + Terraform)
    ├── codepipeline/   # CodePipeline with Source, Build, Deploy stages
    └── ecs-service/    # ECS task definitions and services with circuit breaker
```

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured with appropriate credentials
- Existing infrastructure: VPC, subnets, ECS cluster, ALB with target groups, EFS, DocumentDB, S3 bucket
- GitHub repositories for LibreChat, Admin Portal, and Terraform IaC

## Deploying to a New Environment

### Step 1: Copy the tfvars template

```bash
cp environments/dev/terraform.tfvars environments/<env>/terraform.tfvars
```

### Step 2: Update environment values

Edit `environments/<env>/terraform.tfvars` and replace all `REPLACE_ME` placeholders:

| Variable | Description |
|----------|-------------|
| `environment` | Environment name (e.g., `stage`, `prod`) |
| `vpc_id` | VPC ID for the target environment |
| `subnet_ids` | Private subnet IDs for ECS tasks and CodeBuild |
| `librechat_repo` | GitHub repository (owner/repo format) |
| `admin_portal_repo` | GitHub repository (owner/repo format) |
| `terraform_repo` | GitHub repository (owner/repo format) |
| `ecs_cluster_name` | Existing ECS cluster name |
| `efs_file_system_id` | EFS file system ID |
| `docdb_cluster_endpoint` | DocumentDB cluster endpoint |
| `docdb_secret_arn` | Secrets Manager ARN for DB credentials |
| `s3_bucket_name` | Application data S3 bucket |
| `bedrock_model_id` | Amazon Bedrock model ID |
| `notification_email` | Team email for SNS notifications |
| `ecs_security_group_ids` | Security group IDs for ECS tasks |
| `librechat_target_group_arn` | ALB target group ARN for LibreChat |
| `admin_portal_target_group_arn` | ALB target group ARN for Admin Portal |
| `require_manual_approval` | `false` for dev, `true` for prod |

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
terraform plan -var-file=environments/<env>/terraform.tfvars
terraform apply -var-file=environments/<env>/terraform.tfvars
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
- **3 separate pipelines** — each component has distinct build/deploy requirements
- **Configurable approval gate** — `require_manual_approval = false` for dev, `true` for prod
- **Provider-level default_tags** — UMass mandatory tags applied to all resources automatically
- **Secrets Manager + Parameter Store** — no secrets in source code or S3

## Resources / References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html)
- [Amazon ECR Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [Amazon ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [AWS CodeConnections](https://docs.aws.amazon.com/dtconsole/latest/userguide/welcome-connections.html)
- [Terraform Module Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop)
