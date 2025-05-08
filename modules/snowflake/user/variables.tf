variable "user_name" {
  type    = string
  default = ""
}

variable "user_comment" {
  type    = string
  default = ""
}

# variable "user_password" {
#   type    = string
#   default = ""
# }

variable "user_email" {
  type    = string
  default = null
}

variable "user_first_name" {
  type    = string
  default = null
}

variable "user_last_name" {
  type    = string
  default = null
}

# variable "user_role" {
#   type = string
# }

variable "user_rsa_key" {
  type    = string
  default = null
}

variable "roles" {
  type = list(string)
}
