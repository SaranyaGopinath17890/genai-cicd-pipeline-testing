# -----------------------------------------------------------------------------
# IAM Module — Roles and Policies
# Defines least-privilege IAM roles for CodePipeline, CodeBuild, and ECS.
#
# Roles created:
#   1. codepipeline-role       — CodePipeline service role
#   2. codebuild-role          — CodeBuild role for application image builds
#   3. codebuild-terraform-role — CodeBuild role for Terraform plan/apply
#   4. ecs-task-execution-role — ECS Fargate task execution role
#   5. ecs-task-role           — ECS Fargate task role (runtime permissions)
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # Resolve "use provided ARN or fall back to wildcard" for each resource type
  s3_artifact_bucket_arn  = var.s3_artifact_bucket_arn != "" ? var.s3_artifact_bucket_arn : "arn:aws:s3:::${var.name_prefix}-*"
  sns_topic_arn           = var.sns_topic_arn != "" ? var.sns_topic_arn : "arn:aws:sns:${local.region}:${local.account_id}:${var.name_prefix}-*"
  ecs_cluster_arn         = var.ecs_cluster_arn != "" ? var.ecs_cluster_arn : "arn:aws:ecs:${local.region}:${local.account_id}:cluster/${var.name_prefix}-*"
  efs_file_system_arn     = var.efs_file_system_arn != "" ? var.efs_file_system_arn : "arn:aws:elasticfilesystem:${local.region}:${local.account_id}:file-system/*"
  s3_data_bucket_arn      = var.s3_data_bucket_arn != "" ? var.s3_data_bucket_arn : "arn:aws:s3:::${var.name_prefix}-*"
  codestar_connection_arn = var.codestar_connection_arn != "" ? var.codestar_connection_arn : "arn:aws:codeconnections:${local.region}:${local.account_id}:connection/*"

  terraform_state_bucket_arn = var.terraform_state_bucket_arn != "" ? var.terraform_state_bucket_arn : "arn:aws:s3:::${var.name_prefix}-*"
  terraform_lock_table_arn   = var.terraform_lock_table_arn != "" ? var.terraform_lock_table_arn : "arn:aws:dynamodb:${local.region}:${local.account_id}:table/${var.name_prefix}-*"

  ecr_repository_arns       = length(var.ecr_repository_arns) > 0 ? var.ecr_repository_arns : ["arn:aws:ecr:${local.region}:${local.account_id}:repository/${var.name_prefix}-*"]
  codebuild_project_arns    = length(var.codebuild_project_arns) > 0 ? var.codebuild_project_arns : ["arn:aws:codebuild:${local.region}:${local.account_id}:project/${var.name_prefix}-*"]
  secrets_manager_arns      = length(var.secrets_manager_arns) > 0 ? var.secrets_manager_arns : ["arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.name_prefix}-*"]
  ssm_parameter_arns        = length(var.ssm_parameter_arns) > 0 ? var.ssm_parameter_arns : ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/${var.name_prefix}/*"]
  cloudwatch_log_group_arns = length(var.cloudwatch_log_group_arns) > 0 ? var.cloudwatch_log_group_arns : ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
}

# =============================================================================
# 1. CodePipeline Service Role
# Trust: codepipeline.amazonaws.com
# Permissions: S3 artifacts, CodeBuild start, ECS deploy, SNS publish,
#              CodeConnection (source)
# =============================================================================

resource "aws_iam_role" "codepipeline" {
  name = "${var.name_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.name_prefix}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 artifact bucket — read/write
      {
        Sid    = "S3ArtifactAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          local.s3_artifact_bucket_arn,
          "${local.s3_artifact_bucket_arn}/*"
        ]
      },
      # CodeBuild — start and view builds
      {
        Sid    = "CodeBuildAccess"
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = local.codebuild_project_arns
      },
      # ECS — deploy (update service, describe, register task def)
      # TODO: Scope to specific cluster ARN in production
      {
        Sid    = "ECSDeployAccess"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:TagResource",
          "ecs:ListTagsForResource",
          "ecs:CreateTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:UpdateServicePrimaryTaskSet"
        ]
        Resource = "*"
      },
      # ECS — pass role to task execution and task roles
      {
        Sid    = "PassRoleForECS"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.ecs_task_execution.arn,
          aws_iam_role.ecs_task.arn
        ]
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
      # SNS — publish pipeline notifications
      {
        Sid      = "SNSPublish"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = local.sns_topic_arn
      },
      # CodeConnection — use connection for source stage
      {
        Sid      = "CodeConnectionAccess"
        Effect   = "Allow"
        Action   = "codestar-connections:UseConnection"
        Resource = local.codestar_connection_arn
      }
    ]
  })
}

# =============================================================================
# 2. CodeBuild Service Role (Application Builds)
# Trust: codebuild.amazonaws.com
# Permissions: ECR push/pull, S3 read (artifacts), CloudWatch Logs,
#              Secrets Manager read
# =============================================================================

resource "aws_iam_role" "codebuild" {
  name = "${var.name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR — authenticate, push, and pull images
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = local.ecr_repository_arns
      },
      # S3 — read artifacts from pipeline bucket
      {
        Sid    = "S3ArtifactRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]
        Resource = [
          local.s3_artifact_bucket_arn,
          "${local.s3_artifact_bucket_arn}/*"
        ]
      },
      # CloudWatch Logs — write build logs
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = local.cloudwatch_log_group_arns
      },
      # Secrets Manager — read secrets during build (e.g., Docker Hub creds)
      {
        Sid    = "SecretsManagerRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = local.secrets_manager_arns
      }
    ]
  })
}

# =============================================================================
# 3. CodeBuild Terraform Role
# Trust: codebuild.amazonaws.com
# Permissions: Terraform state S3, DynamoDB lock, resource provisioning (scoped),
#              CloudWatch Logs, S3 artifacts
# =============================================================================

resource "aws_iam_role" "codebuild_terraform" {
  name = "${var.name_prefix}-codebuild-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild_terraform" {
  name = "${var.name_prefix}-codebuild-terraform-policy"
  role = aws_iam_role.codebuild_terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Terraform state — S3 backend
      {
        Sid    = "TerraformStateS3"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          local.terraform_state_bucket_arn,
          "${local.terraform_state_bucket_arn}/*"
        ]
      },
      # Terraform state — DynamoDB lock table
      {
        Sid    = "TerraformStateLock"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = local.terraform_lock_table_arn
      },
      # CloudWatch Logs — write build logs
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = local.cloudwatch_log_group_arns
      },
      # S3 — read/write pipeline artifacts
      {
        Sid    = "S3ArtifactAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          local.s3_artifact_bucket_arn,
          "${local.s3_artifact_bucket_arn}/*"
        ]
      },
      # Resource provisioning — scoped to project-prefixed resources
      # This allows Terraform to manage the infrastructure it creates.
      # TODO: Scope to specific ARN patterns per resource type in production
      {
        Sid    = "ResourceProvisioning"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ecs:*",
          "ecr:*",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole",
          "iam:TagRole",
          "iam:UntagRole",
          "elasticfilesystem:Describe*",
          "elasticloadbalancing:*",
          "codebuild:*",
          "codepipeline:*",
          "codeconnections:*",
          "codestar-connections:*",
          "sns:*",
          "ssm:*",
          "secretsmanager:*",
          "logs:*",
          "cloudwatch:*",
          "events:*",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:PutBucketVersioning",
          "s3:GetBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPublicAccessBlock",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:ResourceTag/Project" = var.name_prefix
          }
        }
      },
      # AssumeRole — allow CodeBuild to assume the dedicated Terraform execution role
      {
        Sid      = "AssumeExecutionRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.terraform_execution.arn
      }
    ]
  })
}

# =============================================================================
# 4. ECS Task Execution Role
# Trust: ecs-tasks.amazonaws.com
# Permissions: ECR pull, Secrets Manager read, Parameter Store read,
#              CloudWatch Logs
# This role is used by the ECS agent to pull images and inject secrets.
# =============================================================================

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach the AWS-managed ECS task execution policy as a baseline
resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional permissions beyond the managed policy
resource "aws_iam_role_policy" "ecs_task_execution" {
  name = "${var.name_prefix}-ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Secrets Manager — inject secrets into container environment
      {
        Sid    = "SecretsManagerRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = local.secrets_manager_arns
      },
      # Parameter Store — inject configuration into container environment
      {
        Sid    = "SSMParameterRead"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = local.ssm_parameter_arns
      },
      # CloudWatch Logs — write container logs
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = local.cloudwatch_log_group_arns
      }
    ]
  })
}

# =============================================================================
# 5. ECS Task Role (Runtime Permissions)
# Trust: ecs-tasks.amazonaws.com
# Permissions: EFS, S3 (application data), DocumentDB (via network),
#              Amazon Bedrock
# This role is assumed by the running container for application-level access.
# =============================================================================

resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # EFS — mount and read/write file system
      {
        Sid    = "EFSAccess"
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = local.efs_file_system_arn
      },
      # S3 — application data bucket read/write
      {
        Sid    = "S3DataAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          local.s3_data_bucket_arn,
          "${local.s3_data_bucket_arn}/*"
        ]
      },
      # Amazon Bedrock — invoke GenAI models
      {
        Sid    = "BedrockAccess"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "arn:aws:bedrock:${local.region}::foundation-model/*"
      },
      # CloudWatch Logs — application-level logging
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = local.cloudwatch_log_group_arns
      }
    ]
  })
}

# =============================================================================
# 6. Terraform Execution Role (AssumeRole target)
# Trust: CodeBuild Terraform role (via sts:AssumeRole)
# Permissions: Scoped resource provisioning for Terraform-managed resources
# This role is assumed by CodeBuild during terraform plan/apply.
#
# Requirements: 20.1, 20.2
# =============================================================================

resource "aws_iam_role" "terraform_execution" {
  name = "${var.name_prefix}-terraform-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.codebuild_terraform.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "terraform_execution" {
  name = "${var.name_prefix}-terraform-execution-policy"
  role = aws_iam_role.terraform_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Resource provisioning — scoped to project-prefixed resources
      # TODO: Scope to specific ARN patterns per resource type in production
      {
        Sid    = "ResourceProvisioning"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ecs:*",
          "ecr:*",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole",
          "iam:TagRole",
          "iam:UntagRole",
          "elasticfilesystem:Describe*",
          "elasticloadbalancing:*",
          "codebuild:*",
          "codepipeline:*",
          "codeconnections:*",
          "codestar-connections:*",
          "sns:*",
          "ssm:*",
          "secretsmanager:*",
          "logs:*",
          "cloudwatch:*",
          "events:*",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:PutBucketVersioning",
          "s3:GetBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPublicAccessBlock",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:ResourceTag/Project" = var.name_prefix
          }
        }
      }
    ]
  })
}
