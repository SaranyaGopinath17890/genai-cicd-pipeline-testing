# Requirements Document

## Introduction

This document defines the requirements for a CI/CD pipeline that automates the provisioning and management of AWS infrastructure using Terraform. The pipeline will handle Terraform plan, apply, and destroy workflows for a single environment, with proper state management, approval gates, and safety checks. Terraform code follows a modular structure with separated configuration files for providers, backend, variables, and resource modules, adhering to UMass tagging standards.

## Glossary

- **Pipeline**: The automated CI/CD workflow that executes Terraform operations in response to code changes or manual triggers
- **Terraform_Runner**: The component within the Pipeline responsible for executing Terraform CLI commands (init, validate, plan, apply, destroy)
- **State_Backend**: The remote storage system (S3 + DynamoDB) used to persist Terraform state files and provide state locking
- **Plan_Artifact**: The output of `terraform plan` saved as a binary plan file for later review and application
- **Environment**: The single deployment target identified by an environment tag on all provisioned resources
- **Approval_Gate**: A conditional manual checkpoint that, when enabled via the `require_manual_approval` Terraform variable, must be passed before Terraform changes are applied. For destroy operations, the Approval_Gate is always required regardless of the variable value
- **Drift_Detection**: The process of comparing actual AWS resource state against the expected Terraform state to identify unauthorized changes
- **Pipeline_Notifier**: The component responsible for sending notifications about pipeline events to configured channels
- **Provider_Config**: The dedicated Terraform file (providers.tf) that declares required providers and their version constraints, separate from resource definitions
- **Backend_Config**: The dedicated Terraform file (backend.tf) that configures the remote state backend, separate from provider and resource definitions
- **Terraform_Module**: A reusable, self-contained package of Terraform configuration files that encapsulates related resources and is called from a root module
- **Tfvars_File**: The variable values file (e.g., `terraform.tfvars`) used to supply variable values for the Environment, stored in the Tfvars_Bucket after initial creation
- **Tfvars_Bucket**: The S3 bucket (which may be the same as or separate from the State_Backend bucket) used to store Tfvars_Files with versioning enabled, ensuring previous variable configurations are retained across deployments
- **UMass_Tags**: The set of mandatory resource tags required by UMass policy: `uma-speed-type`, `uma-function`, and `uma-creator`
- **Environment_Tag**: The `environment` tag applied to all taggable AWS resources to identify which Environment the resources belong to
- **Project_Tags**: The set of additional project-level resource tags applied to all taggable AWS resources: `ARCH` (architecture style), `ENV` (deployment environment), `ORG` (organization identifier), and `PROJECT` (project name). Default values are `ARCH=scalable`, `ENV=dev`, `ORG=umass`, `PROJECT=genai`, and all values are configurable via the Tfvars_File
- **Module_README**: The `README.md` file within each Terraform_Module that documents the module's purpose, inputs, outputs, usage examples, and dependencies
- **ECR_Repository**: The Amazon Elastic Container Registry repository used to store Docker container images built by the Pipeline
- **ECR_Image_Scanner**: The component that performs vulnerability scanning on container images pushed to the ECR_Repository
- **SNS_Topic**: The Amazon Simple Notification Service topic used by the Pipeline_Notifier to publish pipeline event notifications
- **GitHub_Connection**: The AWS CodeStar Connection resource that authenticates and links the Pipeline to a GitHub repository for source code retrieval and event-based triggering
- **GitHub_Repository_Name**: A configurable Terraform variable specifying the full name (owner/repo) of the GitHub repository used as the Pipeline source
- **CloudWatch_Log_Group**: An Amazon CloudWatch Logs log group used to centralize and retain log output from Pipeline services such as CodeBuild, CodePipeline, and Lambda
- **EventBridge_Rule**: An Amazon EventBridge rule that matches pipeline state-change events (e.g., STARTED, SUCCEEDED, FAILED) and routes them to configured targets
- **CloudWatch_Metric**: A custom or built-in Amazon CloudWatch metric used to track pipeline execution counts, durations, and failure rates
- **CloudWatch_Dashboard**: An Amazon CloudWatch dashboard that visualizes CloudWatch_Metrics related to pipeline performance and health in a single view
- **Pipeline_State_Change**: An event emitted by CodePipeline when a pipeline execution transitions between states (STARTED, SUCCEEDED, FAILED, CANCELED, SUPERSEDED)
- **IAM_Role**: An AWS Identity and Access Management role that grants specific permissions to an AWS service, following the principle of least privilege
- **AssumeRole**: The AWS IAM mechanism that allows one entity to temporarily assume the permissions of an IAM_Role, avoiding the need for long-lived credentials
- **Secrets_Manager**: AWS Secrets Manager, a service for securely storing and retrieving sensitive values such as API keys, tokens, and credentials
- **SSM_Parameter_Store**: AWS Systems Manager Parameter Store, a service for storing configuration data and secrets as key-value pairs with optional encryption
- **Pipeline_Timeout**: A configurable time limit applied to pipeline stages or CodeBuild projects to prevent indefinitely running builds
- **Provider_Cache**: A cached copy of the `.terraform` directory containing downloaded Terraform provider binaries, stored in a CodeBuild cache layer to speed up subsequent builds
- **State_Version**: A specific version of the Terraform state file stored in the versioned S3 bucket, used for rollback in case of a failed apply
- **AWS_Budget**: An AWS Budgets resource that tracks cost and usage against a defined threshold and sends alerts when thresholds are approached or exceeded
- **S3_Lifecycle_Policy**: An S3 bucket lifecycle configuration rule that automatically transitions or expires objects after a configurable retention period
- **Terraform_Docs**: The `terraform-docs` CLI tool that auto-generates documentation for Terraform modules based on variables, outputs, and descriptions defined in the module source
- **Infracost**: A cost estimation tool that analyzes Terraform plan output and produces a cost breakdown of infrastructure changes before they are applied
- **Terraform_Lock_File**: The `.terraform.lock.hcl` file that records the exact provider versions and hashes selected during `terraform init`, ensuring reproducible provider installs across environments
- **Notification_Events_Setting**: The configurable Terraform variable (`notification_events`) that determines which pipeline events trigger SNS notifications; valid values are `success_only`, `failure_only`, `both`, and `every_stage`
- **ECR_Notification_Type_Setting**: The configurable Terraform variable (`ecr_notification_type`) that determines which ECR events trigger SNS notifications; valid values are `all`, `scan_result`, and `none`

## CI/CD Requirements

### Requirement 1: Terraform Initialization and Validation

**User Story:** As a DevOps engineer, I want the pipeline to automatically initialize and validate Terraform configurations, so that syntax and configuration errors are caught early.

#### Acceptance Criteria

1. WHEN a pull request is opened or updated, THE Terraform_Runner SHALL execute `terraform init` with the Backend_Config settings from `backend.tf`
2. WHEN initialization completes successfully, THE Terraform_Runner SHALL execute `terraform validate` on the configuration files
3. WHEN initialization completes successfully, THE Terraform_Runner SHALL execute `terraform fmt -check` to verify code formatting across all `.tf` files including Terraform_Modules
4. IF `terraform validate` returns errors, THEN THE Pipeline SHALL fail the pipeline run and report the validation errors in the pull request
5. IF `terraform fmt -check` detects formatting differences, THEN THE Pipeline SHALL fail the pipeline run and list the unformatted files in the pull request

### Requirement 2: Terraform Plan Generation

**User Story:** As a DevOps engineer, I want the pipeline to generate and display Terraform plans on pull requests, so that I can review infrastructure changes before they are applied.

#### Acceptance Criteria

1. WHEN validation passes on a pull request, THE Terraform_Runner SHALL execute `terraform plan` with the Tfvars_File and save the output as a Plan_Artifact
2. WHEN a Plan_Artifact is generated, THE Pipeline SHALL post a summary of the planned changes as a comment on the pull request
3. THE Plan_Artifact SHALL include the count of resources to be added, changed, and destroyed
4. IF `terraform plan` fails, THEN THE Pipeline SHALL fail the pipeline run and report the error details in the pull request

### Requirement 3: Terraform Apply Workflow

**User Story:** As a DevOps engineer, I want Terraform changes to be applied automatically after merge with appropriate safeguards, so that infrastructure stays in sync with the codebase, with the approval gate conditionally enabled based on the environment.

#### Acceptance Criteria

1. WHEN a pull request is merged to the main branch, THE Terraform_Runner SHALL execute `terraform plan` with the Tfvars_File to generate a fresh Plan_Artifact
2. WHILE the `require_manual_approval` Terraform variable is set to `true`, WHEN a Plan_Artifact is generated for apply, THE Approval_Gate SHALL require manual approval before proceeding to apply
3. WHILE the `require_manual_approval` Terraform variable is set to `false`, WHEN a Plan_Artifact is generated for apply, THE Pipeline SHALL skip the Approval_Gate and proceed directly to apply
4. WHEN approval is granted (or the Approval_Gate is skipped), THE Terraform_Runner SHALL execute `terraform apply` using the saved Plan_Artifact
5. IF `terraform apply` fails, THEN THE Pipeline SHALL report the failure details and preserve the Terraform state for manual investigation
6. WHEN `terraform apply` completes successfully, THE Pipeline_Notifier SHALL publish a deployment completion notification to the SNS_Topic with a summary of applied changes

### Requirement 4: Drift Detection

**User Story:** As a DevOps engineer, I want the pipeline to detect infrastructure drift on a schedule, so that unauthorized or manual changes are identified.

#### Acceptance Criteria

1. THE Pipeline SHALL execute Drift_Detection on a configurable schedule (default: daily) for the Environment
2. WHEN Drift_Detection identifies differences between actual AWS resources and the Terraform state, THE Pipeline_Notifier SHALL send an alert with the drift details
3. THE Drift_Detection report SHALL list each drifted resource with the expected and actual values

### Requirement 5: Pipeline Notifications via SNS

**User Story:** As a DevOps engineer, I want to receive configurable SNS notifications about pipeline events, so that I am aware of failures and important state changes through a centralized notification channel, with the ability to control which events trigger notifications.

#### Acceptance Criteria

1. WHILE the `enable_pipeline_notifications` Terraform variable is set to `true`, THE Pipeline_Notifier SHALL publish notifications to the configured SNS_Topic for pipeline events matching the `notification_events` variable setting
2. WHILE the `enable_pipeline_notifications` Terraform variable is set to `false`, THE Pipeline_Notifier SHALL not publish any pipeline event notifications to the SNS_Topic
3. WHILE the `notification_events` Terraform variable is set to `both`, THE Pipeline_Notifier SHALL publish notifications for pipeline run failures and pipeline run successes
4. WHILE the `notification_events` Terraform variable is set to `failure_only`, THE Pipeline_Notifier SHALL publish notifications only for pipeline run failures
5. WHILE the `notification_events` Terraform variable is set to `success_only`, THE Pipeline_Notifier SHALL publish notifications only for pipeline run successes
6. WHILE the `notification_events` Terraform variable is set to `every_stage`, THE Pipeline_Notifier SHALL publish notifications for every pipeline stage transition including STARTED, SUCCEEDED, FAILED, CANCELED, and SUPERSEDED
7. WHEN a failure notification is published, THE Pipeline_Notifier SHALL publish the notification to the configured SNS_Topic within 60 seconds of the failure
8. THE Pipeline_Notifier SHALL use AWS SNS as the notification channel for all pipeline event notifications
9. THE Pipeline_Notifier SHALL include a link to the pipeline run logs in each SNS notification message
10. WHILE the `enable_approval_notifications` Terraform variable is set to `true` and the Approval_Gate is waiting for approval, THE Pipeline_Notifier SHALL publish an approval request notification to the SNS_Topic with the pipeline name, execution ID, and a link to the approval action
11. WHILE the `enable_approval_notifications` Terraform variable is set to `false`, THE Pipeline_Notifier SHALL not publish approval request notifications to the SNS_Topic

### Requirement 6: Terraform Destroy Safeguard

**User Story:** As a DevOps engineer, I want destroy operations to always require explicit confirmation regardless of environment settings, so that infrastructure is not accidentally deleted.

#### Acceptance Criteria

1. THE Pipeline SHALL only allow `terraform destroy` through a manually triggered workflow
2. WHEN a destroy workflow is triggered, THE Approval_Gate SHALL require approval from at least one authorized user regardless of the `require_manual_approval` variable value
3. WHEN a destroy operation completes, THE Pipeline_Notifier SHALL publish a notification to the SNS_Topic listing all destroyed resources

### Requirement 7: ECR Image Scanning and Configurable SNS Notifications

**User Story:** As a DevOps engineer, I want container images in ECR to be scanned for vulnerabilities with configurable SNS notifications, so that I am alerted to security issues in deployed images and can control the level of ECR notification detail.

#### Acceptance Criteria

1. WHEN a container image is pushed to the ECR_Repository, THE ECR_Image_Scanner SHALL initiate a vulnerability scan on the pushed image
2. WHILE the `ecr_notification_type` Terraform variable is set to `scan_result`, THE Pipeline_Notifier SHALL publish only scan result notifications to the configured SNS_Topic when the ECR_Image_Scanner completes a scan
3. WHILE the `ecr_notification_type` Terraform variable is set to `all`, THE Pipeline_Notifier SHALL publish notifications to the configured SNS_Topic for image push events, image push failures, and scan result completions
4. WHILE the `ecr_notification_type` Terraform variable is set to `none`, THE Pipeline_Notifier SHALL not publish any ECR-related notifications to the SNS_Topic
5. IF the ECR_Image_Scanner detects vulnerabilities with severity HIGH or CRITICAL, THEN THE Pipeline_Notifier SHALL publish an alert to the SNS_Topic with the image tag, vulnerability count, and severity breakdown regardless of the `ecr_notification_type` setting (unless set to `none`)
6. IF the ECR_Image_Scanner detects vulnerabilities with severity HIGH or CRITICAL, THEN THE Pipeline SHALL fail the pipeline run and prevent deployment of the affected image
7. WHEN the ECR_Image_Scanner completes a scan with no HIGH or CRITICAL findings and the `ecr_notification_type` is set to `scan_result` or `all`, THE Pipeline_Notifier SHALL publish a clean scan notification to the SNS_Topic with the image tag and scan summary

### Requirement 8: GitHub Repository Connection

**User Story:** As a DevOps engineer, I want the pipeline to connect to a GitHub repository as its source using an AWS-native connection mechanism, so that infrastructure code changes in GitHub automatically trigger pipeline runs.

#### Acceptance Criteria

1. THE Pipeline SHALL use an AWS CodeStar GitHub_Connection to connect to the source GitHub repository
2. THE Pipeline SHALL define the GitHub_Repository_Name as a Terraform variable supplied through the Tfvars_File
3. WHEN the GitHub_Connection is established, THE Pipeline SHALL use the GitHub_Repository_Name variable to identify the source repository
4. WHEN code changes are pushed to the configured branch of the GitHub repository, THE GitHub_Connection SHALL trigger the Pipeline to start a new run
5. WHEN a pull request is opened or updated in the GitHub repository, THE GitHub_Connection SHALL trigger the Pipeline to execute validation and plan stages
6. IF the GitHub_Connection fails to authenticate with GitHub, THEN THE Pipeline SHALL fail the pipeline run and report the connection error details
7. THE GitHub_Connection SHALL be provisioned as a Terraform-managed resource within the Pipeline infrastructure code

## Terraform Requirements

### Requirement 1: Terraform Code Organization

**User Story:** As a DevOps engineer, I want Terraform code organized into separate files and modules, so that the codebase is maintainable, reusable, and follows Terraform best practices.

#### Acceptance Criteria

1. THE Provider_Config SHALL be defined in a dedicated `providers.tf` file, separate from resource definitions in `main.tf`
2. THE Backend_Config SHALL be defined in a dedicated `backend.tf` file, separate from provider and resource definitions
3. THE Pipeline SHALL organize infrastructure resources into Terraform_Modules, with each module encapsulating a logical group of related resources
4. THE root Terraform configuration SHALL call Terraform_Modules to compose the full infrastructure, rather than defining resources inline
5. THE Pipeline SHALL define all input variables in a dedicated `variables.tf` file within each Terraform_Module and the root module
6. THE Pipeline SHALL define all output values in a dedicated `outputs.tf` file within each Terraform_Module and the root module

### Requirement 2: Variable Management and Environment Configuration

**User Story:** As a DevOps engineer, I want AWS region and other environment-specific values managed through variables and a .tfvars file stored in S3, so that configurations are flexible, not hardcoded, and persisted across deployments.

#### Acceptance Criteria

1. THE Pipeline SHALL define the AWS region as a Terraform variable, not as a hardcoded value in any configuration file
2. THE Provider_Config SHALL reference the AWS region variable for provider configuration
3. THE Pipeline SHALL store the Tfvars_File in the Tfvars_Bucket in S3 rather than maintaining the Tfvars_File as a local file in the repository
4. WHEN the Pipeline is deployed for the first time, THE Pipeline SHALL create the Tfvars_File and upload the Tfvars_File to the Tfvars_Bucket
5. WHEN the Pipeline is deployed on subsequent runs, THE Pipeline SHALL retrieve the existing Tfvars_File from the Tfvars_Bucket and use the retrieved Tfvars_File without recreating the Tfvars_File
6. WHEN executing Terraform commands, THE Terraform_Runner SHALL download the Tfvars_File from the Tfvars_Bucket and pass the Tfvars_File using the `-var-file` flag
7. THE Pipeline SHALL not contain hardcoded environment-specific values in `.tf` files; all environment-specific values SHALL be supplied through the Tfvars_File
8. THE Pipeline SHALL define a `require_manual_approval` Terraform variable of type `bool` with a default value of `false`, supplied through the Tfvars_File, to control whether the Approval_Gate is enabled for apply workflows (set to `true` for production environments, `false` for development environments)
9. THE Pipeline SHALL define an `enable_pipeline_notifications` Terraform variable of type `bool` with a default value of `true`, supplied through the Tfvars_File, to control whether pipeline event notifications are sent to the SNS_Topic
10. THE Pipeline SHALL define a `notification_events` Terraform variable of type `string` with a default value of `both`, supplied through the Tfvars_File, to control which pipeline events trigger notifications (valid values: `success_only`, `failure_only`, `both`, `every_stage`)
11. THE Pipeline SHALL define an `enable_approval_notifications` Terraform variable of type `bool` with a default value of `true`, supplied through the Tfvars_File, to control whether approval request notifications are sent to the SNS_Topic when the Approval_Gate is waiting for approval
12. THE Pipeline SHALL define an `ecr_notification_type` Terraform variable of type `string` with a default value of `scan_result`, supplied through the Tfvars_File, to control which ECR events trigger notifications (valid values: `all`, `scan_result`, `none`)
13. IF the Tfvars_File does not exist in the Tfvars_Bucket during the initial deployment, THEN THE Pipeline SHALL create a default Tfvars_File and upload the default Tfvars_File to the Tfvars_Bucket
14. IF the Tfvars_File already exists in the Tfvars_Bucket, THEN THE Pipeline SHALL use the existing Tfvars_File and SHALL NOT overwrite or recreate the Tfvars_File

### Requirement 3: UMass Mandatory Resource Tagging

**User Story:** As a DevOps engineer, I want all AWS resources tagged with UMass mandatory tags, an environment tag, and project-level tags, so that resources comply with university policy and are properly tracked, identified, and categorized.

#### Acceptance Criteria

1. THE Pipeline SHALL apply the following UMass_Tags to every taggable AWS resource: `uma-speed-type`, `uma-function`, and `uma-creator`
2. THE Pipeline SHALL apply the Environment_Tag (`environment`) to every taggable AWS resource to identify which Environment the resources belong to
3. THE Pipeline SHALL apply the following Project_Tags to every taggable AWS resource: `ARCH`, `ENV`, `ORG`, and `PROJECT`
4. THE Pipeline SHALL define the values for `uma-speed-type`, `uma-function`, `uma-creator`, and `environment` as Terraform variables supplied through the Tfvars_File
5. THE Pipeline SHALL define the values for `ARCH`, `ENV`, `ORG`, and `PROJECT` as Terraform variables supplied through the Tfvars_File, with default values of `ARCH=scalable`, `ENV=dev`, `ORG=umass`, and `PROJECT=genai`
6. WHEN a Terraform_Module creates taggable AWS resources, THE Terraform_Module SHALL include the UMass_Tags, the Environment_Tag, and the Project_Tags on each resource
7. THE Pipeline SHALL use a `default_tags` block in the Provider_Config to apply UMass_Tags, the Environment_Tag, and the Project_Tags to all resources created by the AWS provider
8. IF a `terraform plan` output shows a taggable resource without the three UMass_Tags, the Environment_Tag, or any of the four Project_Tags, THEN THE Pipeline SHALL fail the pipeline run and report the missing tags

### Requirement 4: Terraform Module Documentation

**User Story:** As a DevOps engineer, I want each Terraform module to include a README.md file, so that module consumers understand the module's purpose, interface, and usage without reading the source code.

#### Acceptance Criteria

1. THE Terraform_Module SHALL include a `README.md` file in the module's root directory
2. THE `README.md` SHALL contain a description section explaining the module's purpose and the resources it manages
3. THE `README.md` SHALL document all input variables defined in the module's `variables.tf`, including each variable's name, type, description, and default value (if any)
4. THE `README.md` SHALL document all outputs defined in the module's `outputs.tf`, including each output's name and description
5. THE `README.md` SHALL include at least one usage example showing how to call the Terraform_Module from a root module
6. THE `README.md` SHALL list any external dependencies or prerequisites required by the Terraform_Module (e.g., required providers, minimum Terraform version, other modules)
7. IF a Terraform_Module is added or modified without a corresponding `README.md` update, THEN THE Pipeline SHALL flag the pull request with a documentation warning

### Requirement 5: Remote State and Tfvars Management

**User Story:** As a DevOps engineer, I want Terraform state and Tfvars files stored remotely in S3 with versioning and locking, so that concurrent operations do not corrupt the state and previous configurations are retained.

#### Acceptance Criteria

1. THE State_Backend SHALL store Terraform state files in an S3 bucket with versioning enabled, as configured in the Backend_Config file (`backend.tf`)
2. THE State_Backend SHALL use a DynamoDB table for state locking to prevent concurrent modifications
3. THE State_Backend SHALL encrypt state files at rest using server-side encryption
4. IF a state lock cannot be acquired within 60 seconds, THEN THE Terraform_Runner SHALL fail the operation and report the lock conflict
5. THE Tfvars_Bucket SHALL have S3 bucket versioning enabled so that previous versions of the Tfvars_File are retained
6. THE State_Backend S3 bucket SHALL have S3 bucket versioning enabled so that previous versions of Terraform state files are retained
7. THE Tfvars_Bucket SHALL encrypt Tfvars_Files at rest using server-side encryption
8. THE Tfvars_Bucket SHALL be provisioned as a Terraform-managed resource within the Pipeline infrastructure code

### Requirement 6: Terraform and Provider Version Pinning

**User Story:** As a DevOps engineer, I want Terraform and all provider versions pinned and locked, so that builds are reproducible and not affected by unexpected provider updates.

#### Acceptance Criteria

1. THE Provider_Config SHALL declare a `required_version` constraint for Terraform in the `terraform` block within `providers.tf`
2. THE Provider_Config SHALL declare explicit version constraints for all required providers in the `required_providers` block within `providers.tf`
3. THE Pipeline SHALL commit the Terraform_Lock_File (`.terraform.lock.hcl`) to version control alongside the Terraform configuration files
4. WHEN `terraform init` is executed, THE Terraform_Runner SHALL use the Terraform_Lock_File to install the exact provider versions recorded in the lock file
5. IF the Terraform_Lock_File is missing or out of date, THEN THE Pipeline SHALL fail the pipeline run and report that the lock file must be regenerated and committed

## Monitoring Requirements

### Requirement 1: Centralized CloudWatch Logging

**User Story:** As a DevOps engineer, I want logs from CodeBuild, CodePipeline, Lambda, and other pipeline services centralized into CloudWatch Log Groups, so that I can search, analyze, and troubleshoot pipeline activity from a single location.

#### Acceptance Criteria

1. THE Pipeline SHALL create a dedicated CloudWatch_Log_Group for each pipeline service (CodeBuild, CodePipeline, Lambda) with a configurable retention period supplied through the Tfvars_File
2. WHEN a CodeBuild build executes, THE Pipeline SHALL stream build logs to the designated CloudWatch_Log_Group in real time
3. WHEN a Lambda function executes within the Pipeline, THE Pipeline SHALL route Lambda execution logs to the designated CloudWatch_Log_Group
4. THE Pipeline SHALL apply a consistent naming convention to all CloudWatch_Log_Groups using the pattern `/pipeline/{environment}/{service-name}`
5. IF a CloudWatch_Log_Group reaches its configured retention period, THEN THE CloudWatch_Log_Group SHALL automatically expire log events older than the retention period
6. THE Pipeline SHALL define the log retention period as a Terraform variable with a default value of 90 days

### Requirement 2: Pipeline State Change Capture via EventBridge

**User Story:** As a DevOps engineer, I want pipeline state changes captured through EventBridge rules, so that downstream systems and notification channels are informed of pipeline execution progress and failures in real time.

#### Acceptance Criteria

1. THE Pipeline SHALL create an EventBridge_Rule that matches CodePipeline state-change events for the states STARTED, SUCCEEDED, FAILED, CANCELED, and SUPERSEDED
2. WHEN a Pipeline_State_Change event is captured by the EventBridge_Rule, THE EventBridge_Rule SHALL route the event to the configured SNS_Topic
3. WHEN a Pipeline_State_Change event with state FAILED is captured, THE EventBridge_Rule SHALL include the pipeline name, execution ID, failed stage name, and failure reason in the event payload delivered to the SNS_Topic
4. THE EventBridge_Rule SHALL be provisioned as a Terraform-managed resource within the Pipeline infrastructure code
5. IF the EventBridge_Rule fails to deliver an event to the SNS_Topic, THEN THE EventBridge_Rule SHALL retry delivery using the default EventBridge retry policy (up to 185 retries over 24 hours)

### Requirement 3: CloudWatch Metrics and Dashboard

**User Story:** As a DevOps engineer, I want pipeline execution counts, durations, and failure rates tracked via CloudWatch Metrics and displayed on a CloudWatch Dashboard, so that I can monitor pipeline health and performance trends at a glance.

#### Acceptance Criteria

1. THE Pipeline SHALL publish a CloudWatch_Metric for pipeline execution count, incremented each time a pipeline run completes, in a custom namespace `Pipeline/{environment}`
2. THE Pipeline SHALL publish a CloudWatch_Metric for pipeline execution duration (in seconds) for each completed pipeline run in the custom namespace `Pipeline/{environment}`
3. THE Pipeline SHALL publish a CloudWatch_Metric for pipeline failure count, incremented each time a pipeline run ends with state FAILED, in the custom namespace `Pipeline/{environment}`
4. THE Pipeline SHALL create a CloudWatch_Dashboard that displays widgets for pipeline execution count, execution duration (average and p95), and failure rate over configurable time ranges
5. THE CloudWatch_Dashboard SHALL be provisioned as a Terraform-managed resource within the Pipeline infrastructure code
6. WHEN the pipeline failure rate exceeds a configurable threshold (default: 3 failures within 24 hours), THE Pipeline SHALL trigger a CloudWatch alarm that publishes an alert to the SNS_Topic


## IAM & Security Requirements

### Requirement 1: Least-Privilege IAM Roles

**User Story:** As a DevOps engineer, I want each pipeline service to have its own dedicated IAM role with minimal permissions, so that the blast radius of a compromised service is limited and security best practices are followed.

#### Acceptance Criteria

1. THE Pipeline SHALL provision a dedicated IAM_Role for CodePipeline with only the permissions required for pipeline orchestration (e.g., S3 artifact access, CodeBuild invocation, SNS publishing)
2. THE Pipeline SHALL provision a dedicated IAM_Role for CodeBuild with only the permissions required for Terraform execution (e.g., S3 state access, DynamoDB lock access, resource provisioning)
3. THE Pipeline SHALL provision a dedicated IAM_Role for each Lambda function with only the permissions required for that function's specific task
4. THE Pipeline SHALL not share a single IAM_Role across CodePipeline, CodeBuild, and Lambda services
5. THE Pipeline SHALL provision all IAM_Roles as Terraform-managed resources within the Pipeline infrastructure code
6. IF a new pipeline service is added, THEN THE Pipeline SHALL create a new dedicated IAM_Role for that service rather than extending an existing role

### Requirement 2: IAM Role Assumption for Terraform Execution

**User Story:** As a DevOps engineer, I want Terraform execution to use IAM role assumption instead of long-lived credentials, so that credentials are temporary and the risk of credential leakage is minimized.

#### Acceptance Criteria

1. WHEN the Terraform_Runner executes Terraform commands, THE Terraform_Runner SHALL assume a dedicated IAM_Role using the AWS AssumeRole mechanism
2. THE Pipeline SHALL not use hardcoded AWS access keys or secret keys in any configuration file, environment variable, or Terraform source code
3. THE Provider_Config SHALL configure the AWS provider to use AssumeRole for authentication rather than static credentials
4. THE IAM_Role assumed by the Terraform_Runner SHALL be provisioned as a Terraform-managed resource with a trust policy scoped to the CodeBuild service principal

### Requirement 3: Secrets Management

**User Story:** As a DevOps engineer, I want sensitive values stored in a dedicated secrets management service and referenced securely by Terraform, so that secrets are never exposed in plain text within the codebase or pipeline configuration.

#### Acceptance Criteria

1. THE Pipeline SHALL store all sensitive variables (API keys, secrets, tokens) in Secrets_Manager or SSM_Parameter_Store
2. THE Pipeline SHALL not store sensitive values in the Tfvars_File or in plain-text environment variables within CodeBuild project definitions
3. WHEN Terraform configuration requires a sensitive value, THE Terraform configuration SHALL reference the value from Secrets_Manager or SSM_Parameter_Store using a Terraform data source, not as an inline value
4. IF a pull request introduces a sensitive value in plain text within `.tf` files or `.tfvars` files, THEN THE Pipeline SHALL fail the pipeline run and report the violation

## Pipeline Resilience Requirements

### Requirement 1: Pipeline Execution Timeout

**User Story:** As a DevOps engineer, I want configurable timeout limits on pipeline stages and CodeBuild projects, so that stuck or hung builds are automatically terminated and do not consume resources indefinitely.

#### Acceptance Criteria

1. THE Pipeline SHALL define a configurable Pipeline_Timeout for each CodeBuild project, supplied as a Terraform variable through the Tfvars_File
2. THE Pipeline SHALL define a configurable Pipeline_Timeout for each pipeline stage, supplied as a Terraform variable through the Tfvars_File
3. IF a CodeBuild build exceeds its configured Pipeline_Timeout, THEN THE Pipeline SHALL terminate the build and report a timeout failure
4. IF a pipeline stage exceeds its configured Pipeline_Timeout, THEN THE Pipeline SHALL fail the stage and report a timeout failure
5. THE Pipeline SHALL set a default Pipeline_Timeout value for CodeBuild projects of 30 minutes when no override is supplied

### Requirement 2: Artifact Caching

**User Story:** As a DevOps engineer, I want Terraform provider binaries cached between CodeBuild builds, so that pipeline execution is faster and does not re-download providers on every run.

#### Acceptance Criteria

1. THE Pipeline SHALL configure CodeBuild projects to cache the `.terraform` directory as a Provider_Cache between builds
2. WHEN a CodeBuild build starts, THE Terraform_Runner SHALL restore the Provider_Cache before executing `terraform init`
3. WHEN a CodeBuild build completes, THE Pipeline SHALL update the Provider_Cache with the current `.terraform` directory contents
4. THE Provider_Cache SHALL use an S3 bucket or CodeBuild local cache as the cache storage backend, configurable through a Terraform variable

### Requirement 3: Rollback Strategy

**User Story:** As a DevOps engineer, I want a recovery path when terraform apply fails, so that the infrastructure can be restored to a known good state without manual state file manipulation.

#### Acceptance Criteria

1. THE State_Backend SHALL retain previous State_Versions through S3 bucket versioning, enabling rollback to a prior state
2. IF `terraform apply` fails, THEN THE Pipeline SHALL preserve the current Terraform state and the failed Plan_Artifact for investigation
3. IF `terraform apply` fails, THEN THE Pipeline_Notifier SHALL publish a rollback alert to the SNS_Topic with the pipeline name, execution ID, and failure details
4. THE Pipeline SHALL document the rollback procedure for restoring a previous State_Version in the pipeline's operational runbook
5. WHEN a rollback event occurs, THE Pipeline_Notifier SHALL publish a notification to the SNS_Topic indicating that a rollback to a previous State_Version has been initiated

## Cost & Governance Requirements

### Requirement 1: AWS Budget Alerts

**User Story:** As a DevOps engineer, I want AWS Budget alerts tied to pipeline-tagged resources, so that unexpected cost increases from pipeline infrastructure are detected and communicated promptly.

#### Acceptance Criteria

1. THE Pipeline SHALL provision an AWS_Budget resource that tracks costs for resources tagged with the Environment_Tag, UMass_Tags, and Project_Tags associated with the pipeline
2. THE AWS_Budget SHALL define configurable cost threshold percentages (e.g., 80%, 100%) supplied as Terraform variables through the Tfvars_File
3. WHEN an AWS_Budget threshold is exceeded, THE AWS_Budget SHALL publish an alert to the configured SNS_Topic
4. THE AWS_Budget SHALL be provisioned as a Terraform-managed resource within the Pipeline infrastructure code

### Requirement 2: S3 Lifecycle Policies

**User Story:** As a DevOps engineer, I want S3 lifecycle policies on the state bucket and Tfvars bucket to manage old versions, so that storage costs are controlled and stale versions are automatically cleaned up.

#### Acceptance Criteria

1. THE State_Backend S3 bucket SHALL have an S3_Lifecycle_Policy that expires old state file versions after a configurable retention period
2. THE S3_Lifecycle_Policy retention period SHALL be defined as a Terraform variable supplied through the Tfvars_File, with a default value of 90 days
3. WHEN a state file version exceeds the configured retention period, THE S3_Lifecycle_Policy SHALL automatically delete the expired version
4. THE Tfvars_Bucket SHALL have an S3_Lifecycle_Policy that expires old Tfvars_File versions after a configurable retention period
5. THE S3_Lifecycle_Policy for the Tfvars_Bucket SHALL use the same configurable retention period as the State_Backend lifecycle policy
6. THE S3_Lifecycle_Policy SHALL be provisioned as a Terraform-managed resource within the Pipeline infrastructure code

### Requirement 3: Pipeline Infrastructure Tagging

**User Story:** As a DevOps engineer, I want pipeline infrastructure resources (CodePipeline, CodeBuild projects, IAM roles) tagged with UMass tags and the environment tag, so that pipeline resources comply with the same tagging policy as all other provisioned resources.

#### Acceptance Criteria

1. THE Pipeline SHALL apply the UMass_Tags (`uma-speed-type`, `uma-function`, `uma-creator`), the Environment_Tag, and the Project_Tags (`ARCH`, `ENV`, `ORG`, `PROJECT`) to all taggable pipeline infrastructure resources including CodePipeline, CodeBuild projects, and IAM_Roles
2. THE Pipeline SHALL apply the UMass_Tags, the Environment_Tag, and the Project_Tags to all supporting pipeline resources including S3 buckets (State_Backend and Tfvars_Bucket), SNS_Topics, CloudWatch_Log_Groups, and EventBridge_Rules
3. WHEN a new pipeline infrastructure resource is added, THE Pipeline SHALL include the UMass_Tags, the Environment_Tag, and the Project_Tags on the resource
4. IF a `terraform plan` output shows a pipeline infrastructure resource without the UMass_Tags, the Environment_Tag, or the Project_Tags, THEN THE Pipeline SHALL fail the pipeline run and report the missing tags

## Code Quality Requirements

### Requirement 1: Automated README Generation

**User Story:** As a DevOps engineer, I want module README documentation auto-generated using terraform-docs, so that documentation stays in sync with the actual module interface and is never outdated.

#### Acceptance Criteria

1. THE Pipeline SHALL execute Terraform_Docs as a pipeline step to generate Module_README files for each Terraform_Module
2. WHEN a pull request is opened or updated, THE Pipeline SHALL verify that Module_README files are up to date by running Terraform_Docs in check mode
3. IF a Module_README is out of date compared to the module's `variables.tf` and `outputs.tf`, THEN THE Pipeline SHALL fail the pipeline run and report which modules have stale documentation
4. THE Terraform_Docs configuration SHALL be committed to the repository to ensure consistent README formatting across all Terraform_Modules

### Requirement 2: Terraform Cost Estimation

**User Story:** As a DevOps engineer, I want cost estimation of Terraform changes integrated into the pipeline, so that the cost impact of infrastructure changes is visible before they are applied.

#### Acceptance Criteria

1. WHEN a pull request is opened or updated, THE Pipeline SHALL execute Infracost (or a similar cost estimation tool) against the Terraform plan output to estimate the cost impact of the proposed changes
2. WHEN cost estimation completes, THE Pipeline SHALL post the cost estimation summary as a comment on the pull request
3. WHERE a configurable cost threshold is defined, THE Pipeline SHALL fail the pipeline run if the estimated monthly cost increase exceeds the threshold
4. THE cost threshold SHALL be defined as a Terraform variable supplied through the Tfvars_File, with an empty default value that disables the threshold check
