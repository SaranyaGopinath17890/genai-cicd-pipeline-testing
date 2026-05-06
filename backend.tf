terraform {
  backend "s3" {
    bucket         = "umass-state-bucket-test"
    key            = "genai-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "umass-state-table-test"
    profile        = "eq-hm-sandbox"
  }
}

# NOTE: This S3 bucket is provided by the client and also stores the tfvars file.
# The client must ensure:
#   1. Bucket versioning is ENABLED (required for state rollback and tfvars history)
#   2. Server-side encryption is enabled
#   3. DynamoDB table exists for state locking
#
# TFVars file location in the same bucket:
#   s3://umass-genai-terraform-state/cicd-pipeline/terraform.tfvars
#
# After initial deployment, tfvars are updated (not recreated) — versioning
# preserves previous configurations for rollback.
#
# -------------------------------------------------------------------------
# DEPLOYMENT WORKFLOW (run from local):
# -------------------------------------------------------------------------
#
#   # 1. Initialize Terraform
#   terraform init
#
#   # 2. Plan changes
#   terraform plan -var-file=terraform.tfvars
#
#   # 3. Apply changes
#   terraform apply -var-file=terraform.tfvars
#
#   # 4. Copy tfvars to S3 (versioned backup alongside state file)
#   aws s3 cp terraform.tfvars s3://umass-genai-terraform-state/cicd-pipeline/terraform.tfvars
#
# -------------------------------------------------------------------------
