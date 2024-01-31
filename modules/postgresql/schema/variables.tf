variable "schema_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "schema_owner" {
  type = string
}

variable "read_access_roles" {
  type    = list(string)
  default = []
}

variable "write_access_roles" {
  type    = list(string)
  default = []
}

variable "admin_access_roles" {
  type      = list(string)
  sensitive = false
  default   = []
}
