locals {
  rds_engine     = "postgres"
  rds_engine_ver = "12.8"

}

resource "aws_db_parameter_group" "jacobs_parameter_group" {
  name   = "jacobs-rds-parameter-group"
  family = "postgres12"

  parameter {
    name         = "rds.logical_replication"
    value        = 1
    apply_method = "pending-reboot"
  }

  # it yelled at me if this wasn't set to 15 so yeet bby
  parameter {
    name         = "max_wal_senders"
    value        = 15
    apply_method = "pending-reboot"
  }

}

resource "aws_db_instance" "jacobs_rds_tf" {
  allocated_storage       = 20
  max_allocated_storage   = 21
  engine                  = local.rds_engine
  engine_version          = local.rds_engine_ver # newest possible version that's in free tier eligiblity
  instance_class          = "db.t2.micro"
  identifier              = "jacobs-rds-server"
  port                    = 5432
  db_name                 = "jacob_db" # this is the name of the default database that will be created.
  username                = var.jacobs_rds_user
  password                = var.jacobs_rds_pw
  skip_final_snapshot     = true
  publicly_accessible     = true
  deletion_protection     = true
  backup_retention_period = 1     # change this to 0 in august pls & ty
  storage_type            = "gp2" # general purpose ssd
  vpc_security_group_ids  = [aws_security_group.jacobs_rds_security_group_tf.id]
  db_subnet_group_name    = aws_db_subnet_group.jacobs_subnet_group.id
  parameter_group_name    = aws_db_parameter_group.jacobs_parameter_group.name

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }

}
