# IAM GitHub
Terraform Module to create IAM Roles that can only be assumed by GitHub Actions Runners to provide short-lived credentials during CI runs for access to AWS resources (S3, ECR etc).

Only prerequisite is you have to create a `aws_iam_openid_connect_provider` resource for `https://token.actions.githubusercontent.com` and pass it a certificate.