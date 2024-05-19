variable "lambda_name" {
  type = string
}

variable "lambda_log_retention" {
  type    = number
  default = 7
}

variable "lambda_cron" {
  type    = string
  default = "cron(0 * * * ? *)"
}

# https://github.com/keithrozario/Klayers/tree/master/deployments/python3.9
variable "lambda_layers" {
  type = list(string)

}

variable "lambda_env_vars" {
  type = map(any)
}

variable "is_lambda_schedule" {
  type        = bool
  description = "Boolean which will additionally build Scheduling Resources if true, or only build the lambda function if false"
  default     = false
}


variable "lambda_runtime" {
  type    = string
  default = "python3.9"
}


variable "lambda_memory" {
  type    = number
  default = 128
}

variable "lambda_timeout" {
  type    = number
  default = 60
}

variable "lambda_role_policy" {
  type    = string
  default = null
}

variable "lambda_handler" {
  type    = string
  default = "main.lambda_handler"
}

variable "lambda_source_dir" {
  type = string
  # default = "${path.root}/lambdas/${var.lambda_name}/"
}

variable "create_lambda_role_policy" {
  description = "Flag to create and attach the Lambda role policy"
  type        = bool
  default     = false
}
