module "gitops_praq_github_role" {
  source              = "./modules/iam_github"
  iam_role_name       = "gitops-praq"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/gitops_praq"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
}
EOF

}
