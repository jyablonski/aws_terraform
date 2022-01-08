locals {
    env_type_airflow = "Dev" # cant have an apostrophe in the tag name
    env_name_airflow = "Jacob's EC2 Airflow Server"
}

resource "aws_key_pair" "airflow_ec2_key" {
  key_name   = "airflow-ec2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDASt11D8SVlSNJX1/fPdQjipLkfFZrIjbmBwnr4wUMXw+2TogUmJnMI3of8Gv297CE/Zz9VVJMO2Z2+R2Uy/XllhyuQNUYOzD6B7fBm0i/HXhJ1kZwh1DjB1vtOn3rwBVF2ZuXp5gBAdp6welZ2uWzDLB/34lKN89WPNS7f/H//eYLbCrM4e8a2qgbuHqUOMlxida1N6zWgV1Jt1962H3Dd09tEN0H2yGZIUGiGtvSvbvF+YJO6cz7XJ2fU9zJifLBJ6oyfj1DdlScOqTXhpF5KNbx6czJFgwx+oRhCariBt4q4RvRSGt4t73XyIczDYDzyMnQXKQgb7XSOVgTRmyQLwwys+l4fpyE9uOfHkL1RtTAVRbylxVBVsxYt8xYSNyRUNsHLJRBCqRPYCJHLKwJrjyFdvh3u1XBazCNOrYQycHwl6Te8JmfrdESfshzheBUCFw6ZXLGCI8saqQgFh83vj+HkiOVd64H3U2fsijABmLK/YsczTtX39iKyB9Z2rU= jacob@jacob-BigOtisLinux"
}

resource "aws_instance" "jacobs_ec2_airflow" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t3a.medium"
  associate_public_ip_address = true
  security_groups = [aws_security_group.jacobs_task_security_group_tf.id]
  subnet_id = aws_subnet.jacobs_public_subnet.id
  key_name = aws_key_pair.airflow_ec2_key.key_name

  tags = {
    Name        = local.env_name_airflow
    Environment = local.env_type_airflow
  }
}