resource "aws_iam_role" "jacobs_stepfunctions_role" {
  name               = "jacobs_stepfunctions_role"
  description        = "Role created for AWS Step Functions Execution"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.us-east-1.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "jacobs_stepfunction_policy" {
  name        = "jacobs_stepfunctions_policy"
  description = "A policy for step functions to trigger ANY ecs task definitions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect":"Allow",
        "Action": [
          "ecs:RunTask"
        ],
        "Condition": {
          "ArnEquals": {
            "ecs:cluster": "arn:aws:ecs:${var.region}:${local.account_id}:cluster/*"
          }
        },
        "Resource": [
          "arn:aws:ecs:${var.region}:${local.account_id}:task-definition/*"
        ]
    },
    {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
            "*"
        ],
        "Condition": {
            "StringLike": {
                "iam:PassedToService": "ecs-tasks.amazonaws.com"
            }
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment1" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsConsoleFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment2" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_policy.arn
}

# this is what the code for state machine should look like
# you wrap the ecs task definitions together.
# resource "aws_sfn_state_machine" "jacobs_state_machine" {
#   name     = "NBA_ELT_PIPELINE_STATE_MACHINE"
#   role_arn = aws_iam_role.jacobs_stepfunctions_role.arn

#   definition = <<EOF
# {
#   "Comment": "A Hello World example demonstrating various state types of the Amazon States Language",
#   "StartAt": "web_scrape",
#   "States": {
#     "web_scrape": {
#       "Type": "Task",
#       "Resource": "arn:aws:states:::ecs:runTask.sync",
#       "Parameters": {
#         "LaunchType": "FARGATE",
#         "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
#         "TaskDefinition": "${aws_ecs_task_definition.jacobs_ecs_task.arn}"
#       },
#       "Next": "dbt_job"
#     },
#     "dbt_job": {
#       "Type": "Task",
#       "Resource": "arn:aws:states:::ecs:runTask.sync",
#       "Parameters": {
#         "LaunchType": "FARGATE",
#         "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
#         "TaskDefinition": "${aws_ecs_task_definition.jacobs_dbt_task.arn}"
#       },
#       "Next": "ml_pipeline"
#     },
#     "ml_pipeline": {
#       "Type": "Task",
#       "Resource": "arn:aws:states:::ecs:runTask.sync",
#       "Parameters": {
#         "LaunchType": "FARGATE",
#         "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
#         "TaskDefinition": "${aws_ecs_task_definition.jacobs_ecs_task_ml.arn}"
#       }
#     }
#   }
# }
# EOF
# }