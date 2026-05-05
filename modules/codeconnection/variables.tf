# -----------------------------------------------------------------------------
# CodeConnection Module — Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the CodeStar connection"
  type        = string
}

variable "provider_type" {
  description = "The provider type for the connection (e.g., GitHub, Bitbucket)"
  type        = string
  default     = "GitHub"
}

variable "tags" {
  description = "Tags to apply to the connection"
  type        = map(string)
  default     = {}
}
