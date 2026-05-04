# -----------------------------------------------------------------------------
# CodeConnection — GitHub Integration
# Creates an AWS CodeConnection to link CodePipeline with GitHub repositories.
#
# IMPORTANT: After `terraform apply`, the connection will be in PENDING status.
# You must manually confirm it in the AWS Console:
#   1. Go to Developer Tools → Settings → Connections
#   2. Select the connection
#   3. Click "Update pending connection" and authorize with GitHub
#
# Requirements: 1.1, 1.2
# -----------------------------------------------------------------------------

resource "aws_codestarconnections_connection" "github" {
  name          = "${local.name_prefix}-${var.github_connection_name}"
  provider_type = "GitHub"

  tags = local.common_tags
}
