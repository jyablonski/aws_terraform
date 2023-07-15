# 2022-01-19 update: turning off for now.  want to save credits for a bit
# resource "aws_instance" "jacobs_ec2_mlflow" {
#   ami = "ami-0e1d30f2c40c4c701"
#   # ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.jacobs_task_security_group_tf.id]
#   subnet_id                   = aws_subnet.jacobs_public_subnet.id
#   key_name                    = aws_key_pair.mlflow_ec2_key.key_name

#   tags = {
#     Name        = local.mlflow_instance_name
#     Environment = local.mlflow_env_name
#     Terraform   = local.env_terraform
#   }
# }
