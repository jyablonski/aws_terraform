locals {
  ecs_cluster_name  = "jacobs-ecs-ec2-cluster"
  ecs_key_pair_name = "ecs-ec2-cluster-key-pair"
  user_data         = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.ecs_cluster_name}
    ECS_LOGLEVEL=debug
    EOF
  EOT

}
# ^ this is needed to tell EC2 that these instances in the ASG are to be used for this specific ECS Cluster

# The IAM Role the EC2 Instances in the ASG use
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

# mostly copied from aws managed role AmazonEC2ContainerServiceforEC2Role
# these permissions can prolly be limited to specific ECS Clusters or task definitions
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
    value = "disabled"
  }
}

resource "aws_key_pair" "ecs_cluster_key_pair" {
  key_name   = local.ecs_key_pair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOeyO5NJJjnK6h9vF8NHOaUGZcdyNcs7kES9mbIb84wLF1nDmbF/THTMn1MPO8xksQxxq9m4c/GuUMs/r7UymeBEXqXcjcOKh7B2CjkEtnuUzYGAQ2cAtAB6jDMMRBia7U38a77Ks6h+pXw5Ri/LvCnPxBYeXOx41T6F4vQ9dSK/NSyLD3kejTDZ6ZhFvDKxutxaPW2E7OZeRqdxCjJ/eZNi4kC9C8Ypfp4qMmePS4WHMrOaqJP3b0W2XpWgnDFd0DUVD5YHUTwQ9F9rEqHp92CQJ2HgZAV89qHoKdItxaik9o/GKpDA67cpH2ytM6JV87XHeQ9+w39VWeAmDfUOJFtsQdDfZJ83m6mkpA7C41ivpOk0nsXiLkNOKkyJvdD5vqeMq8XnzmNuTtbyjuBHi5ylBPtS60gCRRvkRsqrbhw29GU57D3C/5J8EU2QVTiiqeo3NmdLs81jRuQfyEfJop1CRnGMO75ZgdR/remo91jBzHwhxbXwC7RcKXHJb9y3c="
}


# this is needed for the ASG to boot up ec2 instances used in the ECS Cluster
# image template, the size of the instance, iam profile that the instance assumes, and the bootstrap ecs stuff.
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${local.ecs_cluster_name}-launch-template"
  image_id      = "ami-0fe5f366c083f59ca"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ecs_cluster_key_pair.key_name

  user_data = base64encode(local.user_data)

  vpc_security_group_ids = [aws_security_group.jacobs_task_security_group_tf.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_ec2_instance_profile.arn
  }
}

resource "aws_autoscaling_group" "ecs_ec2_cluster_asg" {
  name                  = "${local.ecs_cluster_name}-asg"
  min_size              = 0
  max_size              = 1
  desired_capacity      = 1 # basically the initial capacity for the ASG.
  protect_from_scale_in = true

  vpc_zone_identifier = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id]

  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
}

# basically this is what actually determines when to spin up new instances, not the ASG.
# you either provide ASG utilization metrics to decide when to spin up new instances, or you do this ecs capacity provider stuff.
resource "aws_ecs_capacity_provider" "ecs_ec2_cluster_config" {
  name = "${local.ecs_cluster_name}-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_ec2_cluster_asg.arn
    managed_termination_protection = "DISABLED" # disabling this - it was causing ecs to not spin up new tasks

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100 # only doing 100 bc 1 instance, if max instances was like 3 then make this like 75 or something
    }
  }
}

# had to manually delete this in the console in order to allow updates to happen
# https://stackoverflow.com/questions/64021278/how-target-capacity-is-calculated-in-aws-ecs-capacity-provider
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
  # campspot test
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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