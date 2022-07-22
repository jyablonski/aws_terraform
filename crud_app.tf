locals {
  beanstalk_app_name        = "jacobs_beanstalk_crud_app"
  beanstalk_app_description = "Crud App test"
  beanstalk_logs_name       = "jacobs_beanstalk_logs"
  beanstalk_stack_name      = "64bit Amazon Linux 2 v3.3.15 running Python 3.8"
  beanstalk_env_name        = "jacobs_beanstalk_config"
}

# pain in the ass tbh sooooooooooo to be continued

# resource "aws_elastic_beanstalk_application" "beanstalk_app" {
#   name        = local.beanstalk_app_name
#   description = local.beanstalk_app_description
# }

# resource "aws_elastic_beanstalk_environment" "beanstalk_app_env" {
#   name                = local.beanstalk_env_name
#   application         = aws_elastic_beanstalk_application.beanstalk_app.name
#   solution_stack_name = local.beanstalk_stack_name
#   tier = "WebServer"

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "VPCId"
#     value     = aws_vpc.jacobs_vpc_tf.id
#   }

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "Subnets"
#     value     = aws_subnet.jacobs_public_subnet.id
#   }
# }