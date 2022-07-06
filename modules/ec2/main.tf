resource "aws_instance" "sample" {
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true

  tags = {
    Name = var.ec2_instance_name
  }
}