# Module: codeconnection

## Purpose

Creates an AWS CodeConnection (CodeStar Connection) to link CodePipeline with source providers such as GitHub or Bitbucket. After `terraform apply`, the connection must be manually confirmed in the AWS Console.

## Resources

| Name | Type |
|------|------|
| [aws_codestarconnections_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the CodeStar connection | `string` | n/a | yes |
| <a name="input_provider_type"></a> [provider\_type](#input\_provider\_type) | The provider type for the connection (e.g., GitHub, Bitbucket) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the connection | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_arn"></a> [connection\_arn](#output\_connection\_arn) | ARN of the CodeStar connection |
| <a name="output_connection_name"></a> [connection\_name](#output\_connection\_name) | Name of the CodeStar connection |
| <a name="output_connection_status"></a> [connection\_status](#output\_connection\_status) | Status of the CodeStar connection |

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
