locals {
  rds_engine     = "postgres"
  rds_engine_ver = "16.3"

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
