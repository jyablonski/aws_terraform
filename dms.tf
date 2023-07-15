resource "aws_iam_role" "jacobs_dms_role" {
  name               = "jacobs_dms_role"
  description        = "Role created for AWS DMS Access"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "dms.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "jacobs_dms_role_attachment1" {
  role       = aws_iam_role.jacobs_dms_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_dms_role_attachment2" {
  role       = aws_iam_role.jacobs_dms_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"

  # It takes some time for these attachments to work, and creating the aws_dms_replication_subnet_group fails if this attachment hasn't completed.
  provisioner "local-exec" {
    command = "sleep 30"
  }

}

resource "aws_dms_replication_subnet_group" "jacobs_replication_subnet_group" {
  replication_subnet_group_description = "Subnet Group for DMS Resources"
  replication_subnet_group_id          = "jacobs-replication-subnet-group"

  subnet_ids = [
    aws_subnet.jacobs_public_subnet.id,
    aws_subnet.jacobs_public_subnet_2.id,
  ]

  depends_on = [
    aws_iam_role_policy_attachment.jacobs_dms_role_attachment2
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Replication = "hellyah"
  }
}

resource "aws_dms_endpoint" "jacobs_dms_postgres_source" {
  database_name               = "jacob_db"
  endpoint_id                 = "jacobs-dms-postgres-source"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  extra_connection_attributes = ""
  username                    = var.jacobs_rds_user
  password                    = var.jacobs_rds_pw
  port                        = 5432
  server_name                 = aws_db_instance.jacobs_rds_tf.address
  ssl_mode                    = "none"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Replication = "hellyah"
  }

}
