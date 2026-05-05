terraform {
  backend "s3" {
    bucket         = "umass-genai-terraform-state"
    key            = "cicd-pipeline/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# NOTE: This S3 bucket is provided by the client and also stores the tfvars file.
# The client must ensure:
#   1. Bucket versioning is ENABLED (required for state rollback and tfvars history)
#   2. Server-side encryption is enabled
#   3. DynamoDB table exists for state locking
#
# TFVars file location in the same bucket:
#   s3://<bucket>/cicd-pipeline/terraform.tfvars
#
# After initial deployment, tfvars are updated (not recreated) — versioning
# preserves previous configurations for rollback.
