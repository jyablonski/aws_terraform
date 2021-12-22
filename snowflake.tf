###################
#                 #
#    SNOWFLAKE    #
#                 #
###################

resource "snowflake_database" "NBA_ELT_DB" {
  name                        = "NBA_ELT_DB"
  data_retention_time_in_days = 0
}

resource "snowflake_schema" "NBA_AIRFLOW" {
  database = "NBA_ELT_DB"
  name     = "NBA_AIRFLOW"

  is_transient        = false
  is_managed          = true
  data_retention_days = 0
}

resource "snowflake_schema" "NBA_AIRFLOW_QA" {
  database = "NBA_ELT_DB"
  name     = "NBA_AIRFLOW_QA"

  is_transient        = false
  is_managed          = true
  data_retention_days = 0
}


resource "snowflake_schema" "TEST_SCHEMA" {
  database = "NBA_ELT_DB"
  name     = "TEST_SCHEMA"

  is_transient        = false
  is_managed          = true
  data_retention_days = 0
}

# resource "aws_iam_role" "jacobs_snowflake_role" {
#   name = "jacobs_snowflake_role"

# }

# resource "aws_iam_role_policy_attachment" "jacobs_snowflake_role_attachment" {
#   role       = aws_iam_role.jacobs_snowflake_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# }

# resource "aws_iam_policy" "snowflake_s3_policy" {
#   name        = "snowflake_s3_policy"
#   path        = "/"
#   description = "Snowflake Policy for Snowpipe"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#               "s3:GetObject",
#               "s3:GetObjectVersion"
#             ],
#             "Resource": "arn:aws:s3:::jacobsbucket97/sample_files/*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:ListBucket",
#                 "s3:GetBucketLocation"
#             ],
#             "Resource": "arn:aws:s3:::jacobsbucket97",
#             "Condition": {
#                 "StringLike": {
#                     "s3:prefix": [
#                         "*"
#                     ]
#                 }
#             }
#         }
#     ]
# })
# }

/* 
https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html'

basically, you make the custom policy for your s3 bucket & prefix path, make the role, 
    create a snowflake storage integration, copy the aws_role_arn & external id of the storage integration to your aws iam role,
    then create a stage for your specified s3 bucket that includes your storage integration, then create a pipe which will transfer data that gets stored in that s3 bucket to the target snowflake table,
    then create snowflake permissions for the pipe role and run show pipes;
    and then go to the s3 bucket and create event notification for all create object types, and create a new SQS topic with the value from the notification_channel column in show pipes;
  
you have to do historical load for any files previously in the bucket that were there before sqs was set up.

*/
# create storage integration s3_int
#   type = external_stage
#   storage_provider = s3
#   enabled = true
#   storage_aws_role_arn = 'arn:aws:iam::324816727452:role/mysnowflakerole'
#   storage_allowed_locations = ('s3://jacobsbucket97/sample_files/');
  
#   DESC INTEGRATION s3_int;
  
#   -- go input aws iam user arn + external id arn into the snowflake_role on aws iam
  
#   USE DATABASE NBA_ELT_DB;
#   USE SCHEMA TEST_SCHEMA;
  
#   create stage mystage
#   url = 's3://jacobsbucket97/sample_files/'
#   storage_integration = s3_int;
  
#   create pipe mypipe auto_ingest=true as
#   copy into mytable
#   from @NBA_ELT_DB.TEST_SCHEMA.mystage
#   file_format = (type = 'CSV');

# grant role snowpipe1 to user ACCOUNTADMIN;
#   -- Create a role to contain the Snowpipe privileges
# create or replace user jyablonski_snowpipe;
# grant usage on schema NBA_ELT_DB.TEST_SCHEMA to role snowpipe1;
# grant ownership on schema NBA_ELT_DB.TEST_SCHEMA to role ACCOUNTADMIN REVOKE CURRENT GRANTS;
# show grants snowpipe1;

# use role securityadmin;

# create or replace role snowpipe1;

# -- Grant the required privileges on the database objects
# grant usage on database NBA_ELT_DB to role snowpipe1;

# grant usage on schema NBA_ELT_DB.TEST_SCHEMA to role snowpipe1;

# grant insert, select on NBA_ELT_DB.TEST_SCHEMA.mytable to role snowpipe1;

# grant usage on stage NBA_ELT_DB.TEST_SCHEMA.mystage to role snowpipe1;

# -- Grant the OWNERSHIP privilege on the pipe object - got stopped here
# grant all privileges on pipe NBA_ELT_DB.TEST_SCHEMA.mypipe to role snowpipe1;

# -- Grant the role to a user
# grant role snowpipe1 to user jyablonski_snowpipe;

# grant role snowpipe1 to user jyablonski;

# -- Set the role as the default role for the user
# alter user jyablonski_snowpipe set default_role = snowpipe1;


# -- for pipe stuff
# use role snowpipe1;
# use database NBA_ELT_DB;
# use schema TEST_SCHEMA;
# show pipes;

# use role accountadmin;
# SELECT count(*) FROM NBA_ELT_DB.TEST_SCHEMA.mytable;

# select * from NBA_ELT_DB.TEST_SCHEMA.mytable;

# copy into mytable
#   from @mystage
#   file_format = (format_name='TEST_SCHEMA_CSV');
  
#   info loading_data;