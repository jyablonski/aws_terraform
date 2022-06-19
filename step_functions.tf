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
        "Service": "states.amazonaws.com"
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

resource "aws_iam_policy" "jacobs_stepfunction_execution_policy" {
  name        = "jacobs_stepfunctions_execution_policy"
  description = "A policy for step functions to have execution rights (damn thats deep)"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "events:PutTargets",
            "events:PutRule",
            "events:DescribeRule",
            "states:ListStateMachines",
            "states:ListActivities",
            "states:CreateStateMachine",
            "states:CreateActivity"
        ],
        "Resource": [
            "*"
        ]
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment1" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment2" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_policy.arn
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment_cloudwatch_logs" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment_eventbridge" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment_cloudwatch_events" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_execution_policy.arn
}

resource "aws_cloudwatch_log_group" "aws_stepfunction_logs" {
  name              = "jacobs_stepfuntion_logs"
  retention_in_days = 7

}

# this is what the code for state machine should look like
# you wrap the ecs task definitions together.
resource "aws_sfn_state_machine" "jacobs_state_machine" {
  name     = "NBA_ELT_PIPELINE_STATE_MACHINE"
  role_arn = aws_iam_role.jacobs_stepfunctions_role.arn
  type     = "STANDARD"

  logging_configuration {
    include_execution_data = true
    level                  = "ERROR"
    log_destination        = "${aws_cloudwatch_log_group.aws_stepfunction_logs.arn}:*"
  }

  definition = <<EOF
{
  "Comment": "NBA ELT PIPELINE - Step Functions Implementation",
  "StartAt": "web_scrape",
  "States": {
    "web_scrape": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
        "TaskDefinition": "${aws_ecs_task_definition.jacobs_ecs_task.arn}",
        "NetworkConfiguration": {
            "AwsvpcConfiguration": {
                "SecurityGroups": ["${aws_security_group.jacobs_task_security_group_tf.id}"],
                "Subnets": ["${aws_subnet.jacobs_public_subnet.id}", "${aws_subnet.jacobs_public_subnet_2.id}"],
                "AssignPublicIp": "ENABLED"
            }
        }
      },
      "Next": "dbt_job"
    },
    "dbt_job": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
        "TaskDefinition": "${aws_ecs_task_definition.jacobs_fake_ecs_task.arn}",
        "NetworkConfiguration": {
            "AwsvpcConfiguration": {
                "SecurityGroups": ["${aws_security_group.jacobs_task_security_group_tf.id}"],
                "Subnets": ["${aws_subnet.jacobs_public_subnet.id}", "${aws_subnet.jacobs_public_subnet_2.id}"],
                "AssignPublicIp": "ENABLED"
            }
        }
      },
      "Next": "ml_pipeline"
    },
    "ml_pipeline": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
        "TaskDefinition": "${aws_ecs_task_definition.jacobs_ecs_task_ml.arn}",
        "NetworkConfiguration": {
            "AwsvpcConfiguration": {
                "SecurityGroups": ["${aws_security_group.jacobs_task_security_group_tf.id}"],
                "Subnets": ["${aws_subnet.jacobs_public_subnet.id}", "${aws_subnet.jacobs_public_subnet_2.id}"],
                "AssignPublicIp": "ENABLED"
            }
        }
      },
      "Retry": [{
          "ErrorEquals": ["States.TaskFailed"],
          "IntervalSeconds": 1200,
          "MaxAttempts": 2,
          "BackoffRate": 1.5
      }],
         "End":true
      }
   }
}

EOF
}

resource "aws_cloudwatch_event_rule" "step_functions_schedule" {
  name                = "jacobs_stepfunctions_schedule" # change this name
  description         = "Run every day at 4am UTC"
  schedule_expression = "cron(0 4 * * ? *)"
}

# resource "aws_cloudwatch_event_target" "step_function_event_target" {
#   target_id = "jacobs_stepfunctions_target"
#   rule      = aws_cloudwatch_event_rule.step_functions_schedule.name
#   arn       = aws_sfn_state_machine.jacobs_state_machine.arn
#   role_arn  = aws_iam_role.jacobs_stepfunctions_role.arn
# }