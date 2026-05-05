# Module: codeconnection

## Purpose

Creates an AWS CodeConnection (CodeStar Connection) to link CodePipeline with source providers such as GitHub or Bitbucket. After `terraform apply`, the connection must be manually confirmed in the AWS Console.

## Resources

| Name | Type |
|------|------|
| [aws_codestarconnections_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the CodeStar connection | string | — | yes |
| `provider_type` | The provider type for the connection (e.g., GitHub, Bitbucket) | string | — | yes |
| `tags` | Tags to apply to the connection | map(string) | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `connection_arn` | ARN of the CodeStar connection |
| `connection_name` | Name of the CodeStar connection |
| `connection_status` | Status of the CodeStar connection |

## Usage Example

```hcl
module "codeconnection" {
  source        = "./modules/codeconnection"
  name          = "genai-cicd-dev-github"
  provider_type = "GitHub"
  tags          = { Environment = "dev" }
}
```

## Dependencies

None.
