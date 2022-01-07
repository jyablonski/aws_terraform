locals {
    env_type_airflow = "Dev" # cant have an apostrophe in the tag name
    env_name_airflow = "Jacob's EC2 Airflow Server"
}

resource "aws_instance" "web" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t3a.medium"
  associate_public_ip_address = true
  security_groups = [aws_security_group.jacobs_task_security_group_tf.id]
  subnet_id = aws_subnet.jacobs_public_subnet.id

  tags = {
    Name        = local.env_name_airflow
    Environment = local.env_type_airflow
  }
}