variable "region"{
    type = string
    sensitive = true
}

variable "access_key"{
    type = string
    sensitive = true
}

variable "secret_key"{
    type = string
    sensitive = true
}

variable "jacobs_cidr_block"{
    type = list(string)
    sensitive = true
}

variable "jacobs_rds_user" {
    type = string
    sensitive = true
}

variable "jacobs_rds_pw" {
    type = string
    sensitive = true
}

variable "jacobs_rds_schema" {
    type = string
    sensitive = true
}

variable "jacobs_email_address" {
    type = string
    sensitive = true
}

variable "jacobs_reddit_user" {
    type = string
    sensitive = true
}

variable "jacobs_reddit_pw" {
    type = string
    sensitive = true
}

variable "jacobs_pw" {
    type = string
    sensitive = true
}

variable "jacobs_reddit_accesskey" {
    type = string
    sensitive = true
}

variable "jacobs_reddit_secretkey" {
    type = string
    sensitive = true
}

variable "pg_host" {
    type = string
    sensitive = true
}

variable "pg_user" {
    type = string
    sensitive = true
}

variable "pg_pass" {
    type = string
    sensitive = true
}

variable "jacobs_bucket" {
    type = string
    sensitive = true
}

variable "lambda_function_name" {
    type = string
    sensitive = true
}

variable "grafana_external_id" {
  type        = string
  description = "This is your Grafana Cloud identifier and is used for security purposes."

  validation {
    condition     = length(var.grafana_external_id) > 0
    error_message = "ExternalID is required."
  }
}

# variable "snowflake_user" {
#     type = string
#     sensitive = true
# }


# variable "snowflake_pw" {
#     type = string
#     sensitive = true
# }

variable "es_master_user" {
    type = string
    sensitive = true
}

variable "es_master_pw" {
    type = string
    sensitive = true
}

variable "jacobs_ip" {
    type = string
    sensitive = true
}