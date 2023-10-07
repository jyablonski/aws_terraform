variable "warehouse_name" {
  type = string
}

variable "warehouse_comment" {
  type    = string
  default = ""
}

variable "warehouse_size" {
  type    = string
  default = "X-SMALL"
}

variable "role_names" {
  type    = list(any)
  default = []
}

variable "warehouse_scaling_policy" {
  type        = string
  description = "Standard, Default, or Legacy."
  default     = ""
}

variable "min_cluster_count" {
  type    = number
  default = 1
}

variable "max_cluster_count" {
  type    = number
  default = 1
}

variable "statement_timeout" {
  type    = number
  default = 1200
}