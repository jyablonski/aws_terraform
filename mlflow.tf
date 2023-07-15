locals {
  mlflow_key_name  = "jacobs_mlflow_key"
  mlflow_user_name = "jacobs-mlflow-user"
}

resource "aws_key_pair" "mlflow_ec2_key" {
  key_name   = local.mlflow_key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRyLAm6oVGPsknQCIp0rSkK/NQpeWNeklu9ejRaY1DzxvvsB+hvZrB8ZTTrc+q2Ydi2UEJe7AVjh8MZQsEOmiF2RE+2DmxyZxVZUNijw0uRYnyolYYdnocOKYLAg+4/oy4C8wZsjdA9rUwBQ8Q131xuAq/O8eKoZjiWuNF2WvFOI7t1rpPw3eqKP93k8mGt1LVLpBHlxFjJRplGDbGKCTq629eJrbRDGmmxClNs3ADZQCdqHAzxxz56+J+ElFsNGw9jbW5LCg3yRJim71JcmTmid45rHQ63GpD93ECMxqshm+M6/v/sHCHp7KV+3chTnkPb9qcGZeaGTfp64qgmSkj1zJuHldN/hBWs9Es9+1swJgHlTNnXlYEI+0iJHQdgut3B8BiI4g9kLgBkbpV6iiW/ij7Ipq9eBZHUkwSC6EIy1pfWPMS0R+zgy6EsxEk9PHaGNlTB/q2a2OQmbSRpdxN3XmC35y+aq2oko0OmkgrZyEFL9mssUe5Pg9XrDlD/fk= jacob@jacob-BigOtisLinux"
}


resource "aws_iam_user" "jacobs_mlflow_user" {
  name = local.mlflow_user_name
}

resource "aws_iam_user_policy_attachment" "jacobs_mlflow_user_attachment_s3" {
  user       = aws_iam_user.jacobs_mlflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_s3_bucket" "jyablonski_mlflow_bucket" {
  bucket = "jyablonski-mlflow-bucket"

  tags = {
    Terraform = local.env_terraform
  }
}
