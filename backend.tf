terraform {
  backend "s3" {
    bucket         = "umass-genai-terraform-state"
    key            = "cicd-pipeline/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
