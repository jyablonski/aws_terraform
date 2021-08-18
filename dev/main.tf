provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key

}

locals {
    env_type = "Dev" # cant have an apostrophe in the tag name
    env_name = "Jacobs TF Project"
}