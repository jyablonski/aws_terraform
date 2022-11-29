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

variable "iam_role_policy" {
  type = string
}
