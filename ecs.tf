resource "aws_ecr_repository" "jacobs_repo" {
  name                 = "jacobs_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "jacobs_repo_policy" {
  repository = aws_ecr_repository.jacobs_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Remove Untagged Images after 1 Day",
            "selection": {
              "tagStatus": "untagged",
              "countType": "sinceImagePushed",
              "countUnit": "days",
              "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecs_cluster" "jacobs_ecs_cluster" {
  name = "jacobs_fargate_cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}
