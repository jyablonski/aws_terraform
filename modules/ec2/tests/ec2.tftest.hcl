mock_provider "aws" {}

variables {
  ec2_ami_id        = "ami-0123456789abcdef0"
  ec2_instance_name = "unit-instance"
  ec2_instance_type = "t3.micro"
}

run "valid_inputs_configure_instance" {
  command = plan

  assert {
    condition     = aws_instance.sample.ami == "ami-0123456789abcdef0"
    error_message = "EC2 AMI should come from ec2_ami_id."
  }

  assert {
    condition     = aws_instance.sample.instance_type == "t3.micro"
    error_message = "EC2 instance type should come from ec2_instance_type."
  }

  assert {
    condition     = aws_instance.sample.associate_public_ip_address == true
    error_message = "Instance should request a public IP."
  }
}

run "name_tag_is_derived" {
  command = plan

  assert {
    condition     = aws_instance.sample.tags.Name == "unit-instance"
    error_message = "Name tag should be derived from ec2_instance_name."
  }
}
