locals {
  rds_engine     = "postgres"
  rds_engine_ver = "16.1"

}

resource "aws_db_parameter_group" "jacobs_parameter_group" {
  name   = "jacobs-rds-parameter-group"
  family = "postgres14"

  parameter {
    name         = "rds.logical_replication"
    value        = 0
    apply_method = "pending-reboot"
  }

  # change to 15 below if you want to do CDC with DMS
  parameter {
    name         = "max_wal_senders"
    value        = 10
    apply_method = "pending-reboot"
  }

}

resource "aws_db_parameter_group" "jacobs_parameter_group_16" {
  name   = "jacobs-rds-parameter-group-pg16"
  family = "postgres16"

  parameter {
    name         = "rds.logical_replication"
    value        = 0
    apply_method = "pending-reboot"
  }

  # change to 15 below if you want to do CDC with DMS
  parameter {
    name         = "max_wal_senders"
    value        = 10
    apply_method = "pending-reboot"
  }

}

resource "aws_db_instance" "jacobs_rds_tf" {
  allocated_storage       = 20
  max_allocated_storage   = 22
  engine                  = local.rds_engine
  engine_version          = local.rds_engine_ver
  instance_class          = "db.t3.micro"
  identifier              = "jacobs-rds-server"
  port                    = 5432
  db_name                 = var.jacobs_rds_db # this is the name of the default database that will be created.
  username                = var.jacobs_rds_user
  password                = var.jacobs_rds_pw
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = true
  backup_retention_period = 0
  storage_type            = "gp2" # general purpose ssd
  vpc_security_group_ids  = [aws_security_group.jacobs_rds_security_group_tf.id]
  db_subnet_group_name    = aws_db_subnet_group.jacobs_subnet_group.id
  parameter_group_name    = aws_db_parameter_group.jacobs_parameter_group_16.name

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }

}

resource "aws_route53_record" "jacobs_rds_route53_record_api" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "rds.${local.website_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.jacobs_rds_tf.address]
}
