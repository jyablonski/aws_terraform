locals {
  ecs_cluster_name = "jacobs-ecs-ec2-cluster"
  user_data        = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.ecs_cluster_name}
    ECS_LOGLEVEL=debug
    EOF
  EOT

}

# need subnets + security groups for this

resource "aws_iam_role" "ecs_ec2_role" {
  name = "${local.ecs_cluster_name}-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

# aws managed role AmazonEC2ContainerServiceforEC2Role
resource "aws_iam_policy" "ecs_ec2_role_policy" {
  name        = "${local.ecs_cluster_name}-policy"
  description = "A test policy for ec2 instances to run ecs cluster tasks"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "${aws_ecr_repository.jacobs_repo.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/ecs/hello-world-ec2"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role_attach1" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = aws_iam_policy.ecs_ec2_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role_attach3" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

resource "aws_iam_instance_profile" "ecs_ec2_instance_profile" {
  name = "${aws_iam_role.ecs_ec2_role.name}-profile"
  role = aws_iam_role.ecs_ec2_role.name
}

resource "aws_ecs_cluster" "ecs_ec2_cluster" {
  name = local.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${local.ecs_cluster_name}-launch-template"
  image_id      = "ami-0fe5f366c083f59ca"
  instance_type = "t2.micro"

  user_data = base64encode(local.user_data)

  vpc_security_group_ids = [aws_security_group.jacobs_task_security_group_tf.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_ec2_instance_profile.arn
  }
}

resource "aws_autoscaling_group" "ecs_ec2_cluster_asg" {
  name                  = "${local.ecs_cluster_name}-asg"
  min_size              = 1
  max_size              = 1
  desired_capacity      = 1
  protect_from_scale_in = true

  vpc_zone_identifier = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id]

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
}

resource "aws_ecs_capacity_provider" "ecs_ec2_cluster_config" {
  name = "${local.ecs_cluster_name}-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_ec2_cluster_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

# had to manually delete this in the console in order to allow updates to happen
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_provider" {
  cluster_name       = aws_ecs_cluster.ecs_ec2_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_ec2_cluster_config.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_ec2_cluster_config.name
  }
}

# have to have > memory in ec2 instance than is assigned in the ecs task definition, or task will be forever stuck in provisioning.

## test role for work
resource "aws_iam_role" "ecs_ec2_role_cs" {
  name = "${local.ecs_cluster_name}-cs-role"

  # Terraform's "jsonencode" function converts a
  # arn:aws:sts::494531898010:assumed-role/AirflowS3Logs-cl4cd06hj01900t0hoszeaqm/botocore-session-1671228174
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::494531898010:role/AirflowS3Logs-cl4cd06hj01900t0fhoszeaqm"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ecs_ec2_cs_role_policy" {
  name        = "${local.ecs_cluster_name}-cs-policy"
  description = "A test policy for cs iam role to run ecs cluster tasks"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecs:RunTask",
                "ecs:DescribeTasks",
                "logs:GetLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "${aws_ecr_repository.jacobs_repo.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/ecs/hello-world-ec2"
        },
        {
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole"
          ],
          "Resource": [
            "arn:aws:iam::288364792694:role/jacobs_ecs_role",
            "arn:aws:aws::494531898010:role/AirflowS3Logs-cl4cd06hj01900t0fhoszeaqm"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:PassRole"
          ],
          "Resource": [
            "arn:aws:iam::288364792694:role/jacobs_ecs_role"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role_cs_attach1" {
  role       = aws_iam_role.ecs_ec2_role_cs.name
  policy_arn = aws_iam_policy.ecs_ec2_cs_role_policy.arn
}