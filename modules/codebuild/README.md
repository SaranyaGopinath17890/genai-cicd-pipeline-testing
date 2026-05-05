# Module: codebuild

## Purpose

Creates an AWS CodeBuild project for Docker image builds or Terraform operations. Supports configurable compute, environment variables, caching, and optional VPC access.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | CodeBuild project name | string | — | yes |
| `service_role_arn` | IAM role ARN | string | — | yes |
| `description` | Project description | string | "" | no |
| `compute_type` | Compute type | string | BUILD_GENERAL1_SMALL | no |
| `image` | Build environment image | string | aws/codebuild/amazonlinux2-x86_64-standard:5.0 | no |
| `privileged_mode` | Enable Docker daemon | bool | true | no |
| `build_timeout` | Timeout in minutes | number | 30 | no |
| `buildspec` | Buildspec path or inline YAML | string | buildspec.yml | no |
| `environment_variables` | List of env vars | list(object) | [] | no |
| `artifact_type` | Artifact type | string | CODEPIPELINE | no |
| `cloudwatch_log_group` | Log group name | string | "" | no |
| `cache_type` | Cache type (NO_CACHE/S3/LOCAL) | string | NO_CACHE | no |
| `cache_location` | S3 cache location | string | "" | no |
| `vpc_config` | VPC configuration | object | null | no |
| `tags` | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `project_name` | CodeBuild project name |
| `project_arn` | CodeBuild project ARN |
| `project_id` | CodeBuild project ID |

## Usage Example

```hcl
module "codebuild_app" {
  source           = "./modules/codebuild"
  name             = "genai-cicd-dev-librechat-build"
  service_role_arn = module.iam.codebuild_role_arn
  buildspec        = "buildspecs/app-buildspec.yml"
}
```

## Dependencies

- `modules/iam` (provides service role ARN)
