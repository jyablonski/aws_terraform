# original mysql server - gbye my sweet prince
# resource "aws_db_instance" "jacobs_rds_tf" {
#   allocated_storage    = 20
#   max_allocated_storage = 21
#   engine               = "mysql"
#   engine_version       = "8.0" # try this or 8.0.23
#   instance_class       = "db.t2.micro"
#   identifier           = "jacobs-rds-server"
#   port                 = 3306
#   name                 = "jacob_db"   # this is the name of the default database that will be created.
#   username             = var.jacobs_rds_user
#   password             = var.jacobs_rds_pw
#   # parameter_group_name = "default.mysql8.0.25" # try this
#   skip_final_snapshot  = true
#   publicly_accessible  = true
#   storage_type         = "gp2" # general purpose ssd
#   vpc_security_group_ids = [aws_security_group.jacobs_rds_security_group_tf.id]
#   db_subnet_group_name = aws_db_subnet_group.jacobs_subnet_group.id

#   tags = {
#     Name        = local.env_name
#     Environment = local.env_type
#   }

# }

resource "aws_db_instance" "jacobs_rds_tf" {
  allocated_storage     = 20
  max_allocated_storage = 21
  engine                = "postgres"
  engine_version        = "12.7" # newest possible version that's in free tier eligiblity
  instance_class        = "db.t2.micro"
  identifier            = "jacobs-rds-server"
  port                  = 5432
  db_name               = "jacob_db" # this is the name of the default database that will be created.
  username              = var.jacobs_rds_user
  password              = var.jacobs_rds_pw
  # parameter_group_name = "default.mysql8.0.25" # try this
  skip_final_snapshot     = true
  publicly_accessible     = true
  deletion_protection     = true
  backup_retention_period = 1
  storage_type            = "gp2" # general purpose ssd
  vpc_security_group_ids  = [aws_security_group.jacobs_rds_security_group_tf.id]
  db_subnet_group_name    = aws_db_subnet_group.jacobs_subnet_group.id

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }

}