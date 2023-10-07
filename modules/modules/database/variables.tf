variable "db_name" {
  type = string
}

variable "db_comment" {
  type = string
  default = ""
}

variable "db_retention_time" {
  type    = number
  default = 1
}

variable "db_is_transient" {
  type        = bool
  default     = false
  description = ""
}

variable "db_ownership_access" {
  type = bool
  default = false
}

variable "db_ownership_roles" {
  type = list
  default = []
}

variable "db_access" {
  type = bool
  default = false
}

variable "db_access_roles" {
  type = list
  default = []
}