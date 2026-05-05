# -----------------------------------------------------------------------------
# CodeConnection Module
# Creates an AWS CodeConnection to link CodePipeline with source providers.
#
# IMPORTANT: After `terraform apply`, the connection will be in PENDING status.
# You must manually confirm it in the AWS Console:
#   1. Go to Developer Tools → Settings → Connections
#   2. Select the connection
#   3. Click "Update pending connection" and authorize with the provider
# -----------------------------------------------------------------------------

resource "aws_codestarconnections_connection" "this" {
  name          = var.name
  provider_type = var.provider_type

  tags = var.tags
}
