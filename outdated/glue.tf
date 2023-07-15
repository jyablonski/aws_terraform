# resource "aws_glue_job" "jacobs_glue_job" {
#   name         = local.glue_job_name
#   role_arn     = aws_iam_role.jacobs_glue_role.arn
#   timeout      = 1      # 1 minute timeout
#   max_capacity = 0.0625 # use 1/16 data processing units
#   max_retries  = 0
#   glue_version = "3.0" # this allows spark 3.1.1 and python 3.7 i think?

#   command {
#     name            = "pythonshell"
#     script_location = "s3://${aws_s3_bucket.jacobs_bucket_tf.bucket}/practice/glue_ingest.py"
#     python_version  = 3
#   }

#   default_arguments = {
#     "--job-language"                     = "python"
#     "--continuous-log-logGroup"          = aws_cloudwatch_log_group.jacobs_glue_logs.name
#     "--enable-continuous-cloudwatch-log" = "true"
#     "--enable-continuous-log-filter"     = "true"
#     "--enable-metrics"                   = ""
#   }
# }