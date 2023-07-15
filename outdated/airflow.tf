# 2022-05-22 update: turning off for now.  want to save credits for a bit
# resource "aws_instance" "jacobs_ec2_airflow_dev" {
#   ami           = "ami-0ed9277fb7eb570c9"
#   instance_type = "t3a.medium"
#   associate_public_ip_address = true
#   vpc_security_group_ids = [aws_security_group.jacobs_task_security_group_tf.id]
#   subnet_id = aws_subnet.jacobs_public_subnet.id
#   key_name = aws_key_pair.airflow_ec2_key.key_name

#   tags = {
#     Name        = local.env_name_airflow
#     Environment = local.env_type_airflow
#   }
# }