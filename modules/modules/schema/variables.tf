variable "db_name" {
  type = string
}

variable "schema_name" {
  type = string
}

variable "schema_comment" {
  type = string
  default = ""
}

variable "schema_is_transient" {
  type    = bool
  default = false
}

variable "schema_is_managed" {
  type    = bool
  default = false
}

variable "schema_retention_days" {
  type    = number
  default = 1
}

variable "schema_usage_roles" {
  type = list
  default = []
}

variable "schema_all_roles" {
  type = list
  default = []
}

variable "schema_read_roles" {
  type = list
  default = []
}

variable "schema_all_access" {
  type    = bool
  default = false
}

variable "schema_read_access" {
  type    = bool
  default = false
}