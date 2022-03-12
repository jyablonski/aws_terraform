locals {
  mlflow_key_name      = "jacobs_mlflow_key"
  mlflow_env_name      = "Dev"
  mlflow_instance_name = "jacobs_mlflow_server"
}

resource "aws_key_pair" "mlflow_ec2_key" {
  key_name   = local.mlflow_key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRyLAm6oVGPsknQCIp0rSkK/NQpeWNeklu9ejRaY1DzxvvsB+hvZrB8ZTTrc+q2Ydi2UEJe7AVjh8MZQsEOmiF2RE+2DmxyZxVZUNijw0uRYnyolYYdnocOKYLAg+4/oy4C8wZsjdA9rUwBQ8Q131xuAq/O8eKoZjiWuNF2WvFOI7t1rpPw3eqKP93k8mGt1LVLpBHlxFjJRplGDbGKCTq629eJrbRDGmmxClNs3ADZQCdqHAzxxz56+J+ElFsNGw9jbW5LCg3yRJim71JcmTmid45rHQ63GpD93ECMxqshm+M6/v/sHCHp7KV+3chTnkPb9qcGZeaGTfp64qgmSkj1zJuHldN/hBWs9Es9+1swJgHlTNnXlYEI+0iJHQdgut3B8BiI4g9kLgBkbpV6iiW/ij7Ipq9eBZHUkwSC6EIy1pfWPMS0R+zgy6EsxEk9PHaGNlTB/q2a2OQmbSRpdxN3XmC35y+aq2oko0OmkgrZyEFL9mssUe5Pg9XrDlD/fk= jacob@jacob-BigOtisLinux"
}

# 2022-01-19 update: turning off for now.  want to save credits for a bit
resource "aws_instance" "jacobs_ec2_airflow" {
  ami                         = "ami-0b6539181920009de"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jacobs_task_security_group_tf.id]
  subnet_id                   = aws_subnet.jacobs_public_subnet.id
  key_name                    = aws_key_pair.mlflow_ec2_key.key_name

  tags = {
    Name        = local.mlflow_instance_name
    Environment = local.mlflow_env_name
    Terraform   = local.env_terraform
  }
}
