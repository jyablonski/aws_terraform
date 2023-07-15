# resource "aws_dms_endpoint" "jacobs_dms_s3_target" {
#   endpoint_id                 = "jacobs-dms-s3-target"
#   endpoint_type               = "target"
#   engine_name                 = "s3"
#   extra_connection_attributes = "bucketFolder=dms;bucketName=jacobsbucket97-dev;compressionType=NONE;csvDelimiter=,;csvRowDelimiter=\n;datePartitionEnabled=true;"

#   s3_settings {
#     bucket_name              = aws_s3_bucket.jacobs_bucket_tf_dev.id
#     bucket_folder            = "dms"
#     add_column_name          = true
#     date_partition_delimiter = "UNDERSCORE"
#     date_partition_enabled   = true
#     service_access_role_arn  = aws_iam_role.jacobs_dms_role.arn
#   }

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Replication = "hellyah"
#   }

# }

# disabling bc transaction log backups take up a ton of storage on rds
# resource "aws_dms_replication_task" "jacobs_replication_task" {
#   #   cdc_start_position       = "2022-07-30T11:25:00"
#   migration_type           = "full-load-and-cdc"
#   replication_instance_arn = aws_dms_replication_instance.jacobs_replication_instance.replication_instance_arn
#   replication_task_id      = "jacobs-dms-replication-task"
#   source_endpoint_arn      = aws_dms_endpoint.jacobs_dms_postgres_source.endpoint_arn
#   table_mappings = jsonencode({
#     "rules" : [
#       {
#         "rule-type" : "selection",
#         "rule-id" : "1",
#         "rule-name" : "1",
#         "object-locator" : {
#           "schema-name" : "nba_source",
#           "table-name" : "aws_injury_data_source"
#         },
#         "rule-action" : "include",
#         "filters" : []
#       },
#       {
#         "rule-type" : "selection",
#         "rule-id" : "2",
#         "rule-name" : "2",
#         "object-locator" : {
#           "schema-name" : "nba_source",
#           "table-name" : "aws_transactions_source"
#         },
#         "rule-action" : "include",
#         "filters" : []
#       }
#     ]
#   })
#   target_endpoint_arn    = aws_dms_endpoint.jacobs_dms_s3_target.endpoint_arn
#   start_replication_task = true

#   lifecycle { ignore_changes = [replication_task_settings] }
#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Replication = "hellyah"
#   }

# }

# works but the first cell in the csv in s3 is fkn missing for some reason idk so headers are 1 spot out of order

### my stuff
# resource "aws_dms_replication_instance" "jacobs_replication_instance" {
#   allocated_storage            = 50
#   apply_immediately            = true
#   auto_minor_version_upgrade   = true
#   availability_zone            = "us-east-1a"
#   engine_version               = "3.4.7"
#   multi_az                     = false
#   preferred_maintenance_window = "sat:01:30-sat:04:30"
#   publicly_accessible          = true
#   replication_instance_class   = "dms.t2.micro"
#   replication_instance_id      = "jacobs-replication-instance"
#   replication_subnet_group_id  = aws_dms_replication_subnet_group.jacobs_replication_subnet_group.id
#   vpc_security_group_ids       = [aws_security_group.jacobs_task_security_group_tf.id]

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Replication = "hellyah"
#   }

# }