# -----------------------------------------------------------------------------
# ECR Module — Variables
# Inputs for ECR repository configuration and lifecycle policies.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether images are scanned for vulnerabilities on push"
  type        = bool
  default     = true
}

variable "max_tagged_image_count" {
  description = "Maximum number of tagged images to retain (oldest beyond this count are expired)"
  type        = number
  default     = 10
}

variable "tagged_prefix_list" {
  description = "Tag prefixes to match for the tagged image retention rule"
  type        = list(string)
  default     = ["dev", "stage"]
}

variable "untagged_image_expiry_days" {
  description = "Number of days after which untagged images are expired"
  type        = number
  default     = 7
}

variable "force_delete" {
  description = "Whether to delete the repository even if it contains images"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
