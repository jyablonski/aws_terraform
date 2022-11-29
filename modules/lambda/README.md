# Lambda
Terraform Module used to create Python Lambda Functions and optionally schedule them using Cloudwatch Event Rules.  It uses Terraform's `archive_file` to ZIP up Python code in a local `lambdas/` subdirectory and push it to AWS Lambda.  The folder name of this subdirectory must match the name you pass into the `lambda_name` variable.

There are variables to optionally provide a list of Python Layers to add packages like SQLAlchemy or Requests etc, and Environment Variables.