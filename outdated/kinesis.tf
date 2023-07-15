# this creates the data stream - cancelling as of 2022-03-23 bc it costs money daily even if no data is being sent through bc of the shard
# resource "aws_kinesis_stream" "jacobs_kinesis_stream" {
#   name             = local.kinesis_stream_name
#   shard_count      = 1
#   retention_period = 24
#   encryption_type  = "NONE"


#   stream_mode_details {
#     stream_mode = "PROVISIONED"
#   }

#   tags = {
#     Environment = local.project_name
#     Terraform   = local.Terraform
#   }
# }
