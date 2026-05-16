variable "iam_role_name" {
  type = string
}

variable "github_provider_arn" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "example format: jyablonski/kafka_faker_stream"
}

variable "github_sub" {
  type        = string
  default     = null
  description = "Optional full GitHub OIDC sub claim. Defaults to repo:<github_repo>:*."
}

variable "iam_role_policy" {
  type = string
}
