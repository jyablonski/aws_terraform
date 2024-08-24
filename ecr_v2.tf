locals {
  ecr_repos = [
    "jyablonski/ecr-repo1",
    "jyablonski/ecr-repo2"
  ]
}

resource "aws_ecr_repository" "ecr_repos_v2" {
  for_each             = { for repo in local.ecr_repos : repo => true }
  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_repos_v2_policy" {
  for_each   = { for repo in local.ecr_repos : repo => true }
  repository = aws_ecr_repository.ecr_repos_v2[each.key].name

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