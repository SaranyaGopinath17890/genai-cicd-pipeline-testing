# AWS CI/CD Pipeline — Requirements Summary

## CI/CD Requirements

1. **Terraform Initialization and Validation** — Auto-run `terraform init`, `validate`, and `fmt -check` on every PR to catch errors early.
2. **Terraform Plan Generation** — Generate and post Terraform plan summaries as PR comments for review before apply.
3. **Terraform Apply Workflow** — Auto-apply after merge; manual approval gate controlled by `require_manual_approval` parameter (false for dev, true for prod).
4. **Drift Detection** — Scheduled daily drift detection with SNS alerting on differences.
5. **Pipeline Notifications via SNS** — Configurable notifications: `enable_pipeline_notifications` (on/off), `notification_events` (both/success_only/failure_only/every_stage), `enable_approval_notifications` for approval requests.
6. **Terraform Destroy Safeguard** — Restrict destroy to manual trigger with approval gate (always required, regardless of environment).
7. **ECR Image Scanning and Configurable SNS Notifications** — Scan on push to ECR; notification level controlled by `ecr_notification_type` (scan_result/all/none); blocks deployment on HIGH/CRITICAL.
8. **GitHub Repository Connection** — Connect to a GitHub repo via AWS CodeStar Connection; repo name provided as a variable.

## Terraform Requirements

1. **Terraform Code Organization** — Separate providers.tf, backend.tf, variables.tf, outputs.tf, and modular resource structure.
2. **Variable Management and Environment Configuration** — TFVars stored in S3 bucket; created on initial deployment, retained and reused (not recreated) on subsequent runs.
3. **UMass Mandatory Resource Tagging** — Apply uma-speed-type, uma-function, uma-creator, environment, ARCH, ENV, ORG, and PROJECT tags to all resources via default_tags (defaults: ARCH=scalable, ENV=dev, ORG=umass, PROJECT=genai).
4. **Terraform Module Documentation** — Each module includes a README.md with purpose, inputs, outputs, usage examples, and dependencies.
5. **Remote State and Tfvars Management** — S3 backend with versioning for both state files and tfvars, DynamoDB locking, and encryption at rest.
6. **Terraform and Provider Version Pinning** — Pin Terraform and provider versions in providers.tf; commit .terraform.lock.hcl to version control.

## Monitoring Requirements

1. **Centralized CloudWatch Logging** — Stream CodeBuild, CodePipeline, and Lambda logs to dedicated CloudWatch Log Groups with configurable retention.
2. **Pipeline State Change Capture via EventBridge** — Capture pipeline state changes (STARTED, SUCCEEDED, FAILED, etc.) via EventBridge rules and route to SNS.
3. **CloudWatch Metrics and Dashboard** — Track pipeline execution counts, durations, and failure rates with a CloudWatch Dashboard and failure-rate alarms.

## IAM & Security Requirements

1. **Least-Privilege IAM Roles** — Dedicated IAM role per service (CodePipeline, CodeBuild, Lambda) with minimal permissions.
2. **IAM Role Assumption for Terraform Execution** — Use AssumeRole for Terraform execution; no hardcoded AWS credentials anywhere.
3. **Secrets Management** — Store sensitive values in Secrets Manager or SSM Parameter Store; never in tfvars or plain-text env vars.

## Pipeline Resilience Requirements

1. **Pipeline Execution Timeout** — Configurable timeout limits on pipeline stages and CodeBuild projects to prevent hung builds.
2. **Artifact Caching** — Cache .terraform provider directory between CodeBuild builds to speed up pipeline execution.
3. **Rollback Strategy** — Preserve previous state versions for rollback on failed apply; SNS notification on rollback events.

## Cost & Governance Requirements

1. **AWS Budget Alerts** — AWS Budgets with cost threshold alerts tied to pipeline-tagged resources, published to SNS.
2. **S3 Lifecycle Policies** — Lifecycle policies on state bucket and tfvars bucket to auto-expire old versions after configurable retention.
3. **Pipeline Infrastructure Tagging** — Tag pipeline resources (CodePipeline, CodeBuild, IAM roles, S3 buckets) with UMass and environment tags.

## Code Quality Requirements

1. **Automated README Generation** — Use terraform-docs to auto-generate and verify module READMEs in the pipeline.
2. **Terraform Cost Estimation** — Integrate Infracost to estimate cost impact of changes and post as PR comments.
