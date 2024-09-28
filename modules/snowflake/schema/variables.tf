variable "db_name" {
  type = string
}

variable "schema_name" {
  type = string
}

variable "schema_comment" {
  type    = string
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

variable "schema_admin_roles" {
  type    = list(any)
  default = []
}

variable "schema_write_roles" {
  type    = list(any)
  default = []
}

variable "schema_read_roles" {
  type    = list(any)
  default = []
}
