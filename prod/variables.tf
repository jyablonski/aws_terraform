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