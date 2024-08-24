locals {
  dash_service_name = "nba_elt_dashboard"
}

# resource "aws_ecs_service" "dash_dashboard" {
#   name                               = local.dash_service_name
#   cluster                            = aws_ecs_cluster.ecs_ec2_cluster.id
#   task_definition                    = module.dash_ecs_module.ecs_task_definition_arn
#   desired_count                      = 1
#   deployment_minimum_healthy_percent = 1
#   deployment_maximum_percent         = 100
#   launch_type                        = "EC2"

# }

module "nba_elt_dashboard_repo" {
  source              = "./modules/iam_github"
  iam_role_name       = "nba-elt-dashboard"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/nba_elt_dashboard"
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
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Action": [
                "ecs:ListTasks",
                "ecs:StopTask"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowECSListStopTasks"
        }
    ]
}
EOF

}