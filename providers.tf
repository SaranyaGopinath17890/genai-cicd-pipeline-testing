# -----------------------------------------------------------------------------
# AWS Provider Configuration
# Includes UMass mandatory resource tagging via default_tags.
#
# All resources created by this provider automatically inherit these tags.
# Individual resources can override specific tag values when needed.
#
# Requirements: 11.1, 11.2, 11.3, 11.4
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      "uma-speed-type" = var.uma_speed_type
      "uma-function"   = var.uma_function
      "uma-creator"    = var.uma_creator
      "environment"    = var.environment
      "ARCH"           = var.tag_arch
      "ENV"            = var.environment
      "ORG"            = var.tag_org
      "PROJECT"        = var.tag_project
    }
  }
}
