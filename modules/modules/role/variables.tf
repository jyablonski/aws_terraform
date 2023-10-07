variable "role_name" {
  type = string
}

variable "role_comment" {
  type = string
}

variable "role_warehouse_size" {
  type    = string
  default = "X-SMALL"
}

variable "role_warehouse_privilege" {
  type = string
  default = "OPERATE"
}
