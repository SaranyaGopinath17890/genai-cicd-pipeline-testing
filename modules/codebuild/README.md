# Module: codebuild

## Purpose

Creates an AWS CodeBuild project for Docker image builds or Terraform operations. Supports configurable compute, environment variables, caching, and optional VPC access.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the CodeBuild project | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the CodeBuild project | `string` | n/a | yes |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | ARN of the IAM role for the CodeBuild project | `string` | n/a | yes |
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | CodeBuild compute type (BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE) | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Docker image for the build environment | `string` | n/a | yes |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | Whether to enable Docker daemon inside the build container | `bool` | n/a | yes |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Build timeout in minutes | `number` | n/a | yes |
| <a name="input_buildspec"></a> [buildspec](#input\_buildspec) | Path to the buildspec file relative to source root, or inline buildspec YAML | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | List of environment variables for the build | `list(object)` | n/a | yes |
| <a name="input_artifact_type"></a> [artifact\_type](#input\_artifact\_type) | Type of build output artifact (CODEPIPELINE, S3, NO_ARTIFACTS) | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | CloudWatch Logs log group name for build logs | `string` | n/a | yes |
| <a name="input_cloudwatch_log_stream"></a> [cloudwatch\_log\_stream](#input\_cloudwatch\_log\_stream) | CloudWatch Logs stream prefix for build logs | `string` | n/a | yes |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | Cache type (NO_CACHE, S3, LOCAL) | `string` | n/a | yes |
| <a name="input_cache_location"></a> [cache\_location](#input\_cache\_location) | S3 bucket location for cache (required when cache_type is S3) | `string` | n/a | yes |
| <a name="input_cache_modes"></a> [cache\_modes](#input\_cache\_modes) | Cache modes for LOCAL cache type | `list(string)` | n/a | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for CodeBuild (set to null to disable) | `object` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the CodeBuild project | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the CodeBuild project |
| <a name="output_project_arn"></a> [project\_arn](#output\_project\_arn) | ARN of the CodeBuild project |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the CodeBuild project |

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
