variable "region" {
  type      = string
  sensitive = true
}

variable "jacobs_cidr_block" {
  type      = list(string)
  sensitive = true
}

variable "jacobs_rds_user" {
  type      = string
  sensitive = true
}

variable "jacobs_rds_pw" {
  type      = string
  sensitive = true
}

variable "jacobs_rds_schema" {
  type      = string
  sensitive = true
}

variable "jacobs_email_address" {
  type      = string
  sensitive = true
}

variable "jacobs_reddit_user" {
  type      = string
  sensitive = true
}

variable "jacobs_reddit_pw" {
  type      = string
  sensitive = true
}

variable "jacobs_pw" {
  type      = string
  sensitive = true
}

variable "jacobs_reddit_accesskey" {
  type      = string
  sensitive = true
}

variable "jacobs_reddit_secretkey" {
  type      = string
  sensitive = true
}

variable "jacobs_bucket" {
  type      = string
  sensitive = true
}

variable "lambda_function_name" {
  type      = string
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

variable "es_master_pw" {
  type      = string
  sensitive = true
}

variable "jacobs_rds_db" {
  type      = string
  sensitive = true
}

variable "jacobs_rds_schema_ml" {
  type      = string
  sensitive = true
}

variable "jacobs_sentry_token" {
  type      = string
  sensitive = true
}

variable "jacobs_twitter_key" {
  type      = string
  sensitive = true
}

variable "jacobs_twitter_secret" {
  type      = string
  sensitive = true
}

variable "default_tags" {
  default     = {}
  description = "Additional default tags to merge into the provider-level AWS tagging policy."
  type        = map(string)
}

variable "honeycomb_endpoint" {
  type      = string
  sensitive = true
}

variable "honeycomb_headers" {
  type      = string
  sensitive = true
}

variable "honeycomb_app_name" {
  type      = string
  sensitive = true
}

variable "rest_api_api_key" {
  type      = string
  sensitive = true
}

variable "ingestion_webhook_url" {
  type      = string
  sensitive = true
}

variable "dashboard_refresh_url" {
  type      = string
  sensitive = true
}

variable "data_refresh_token" {
  type      = string
  sensitive = true
}

variable "api_gmail_oauth_id" {
  type      = string
  sensitive = true
}

variable "api_gmail_oauth_client_secret" {
  type      = string
  sensitive = true
}

variable "api_gmail_oauth_redirect_url" {
  type      = string
  sensitive = true
}

variable "redis_url" {
  type      = string
  sensitive = true
}

variable "postgres_username" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_host" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "oci_tenancy_ocid" {
  description = "OCID of the OCI tenancy (the root compartment)."
  type        = string

  validation {
    condition     = startswith(var.oci_tenancy_ocid, "ocid1.tenancy.")
    error_message = "oci_tenancy_ocid must be an OCI tenancy OCID."
  }
}

variable "oci_compartment_ocid" {
  description = "OCID of the OCI compartment in which to create resources."
  type        = string

  validation {
    condition     = startswith(var.oci_compartment_ocid, "ocid1.compartment.")
    error_message = "oci_compartment_ocid must be an OCI compartment OCID."
  }
}

variable "oci_region" {
  description = "OCI home region. Always Free resources must be created in the tenancy home region."
  type        = string
  default     = "us-phoenix-1"

  validation {
    condition     = var.oci_region == "us-phoenix-1"
    error_message = "This configuration is cost-guarded for the tenancy home region, us-phoenix-1."
  }
}

variable "oci_ssh_public_key" {
  description = "SSH public key installed for the Ubuntu user."
  type        = string

  validation {
    condition     = startswith(trimspace(var.oci_ssh_public_key), "ssh-") || startswith(trimspace(var.oci_ssh_public_key), "ecdsa-")
    error_message = "oci_ssh_public_key must contain an OpenSSH-format public key."
  }
}
