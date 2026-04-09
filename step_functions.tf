resource "aws_iam_role" "jacobs_stepfunctions_event_role" {
  name               = "jacobs_stepfunctions_event_role"
  description        = "Role created for EventBridge to trigger Step Functions Jobs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "jacobs_stepfunction_event_policy" {
  name        = "jacobs_stepfunctions_event_policy"
  description = "A policy for EventBridge to Trigger Step Functions Jobs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution",
        ]
        Resource = [
          aws_sfn_state_machine.jacobs_state_machine.arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_event_role_attachment" {
  role       = aws_iam_role.jacobs_stepfunctions_event_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_event_policy.arn
}

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
  description = "Least-privilege policy for Step Functions to run ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RunSpecificEcsTasks"
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
        ]
        Condition = {
          ArnEquals = {
            "ecs:cluster" = aws_ecs_cluster.jacobs_ecs_cluster.arn
          }
        }
        Resource = [
          module.webscrape_ecs_module.ecs_task_definition_arn,
          module.dbt_ecs_module.ecs_task_definition_arn,
          module.ml_ecs_module.ecs_task_definition_arn,
        ]
      },
      {
        Sid    = "ManageStartedTasks"
        Effect = "Allow"
        Action = [
          "ecs:DescribeTasks",
          "ecs:StopTask",
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "ecs:cluster" = aws_ecs_cluster.jacobs_ecs_cluster.arn
          }
        }
      },
      {
        Sid    = "PassEcsTaskRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          aws_iam_role.jacobs_ecs_role.arn,
        ]
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "jacobs_stepfunction_events_policy" {
  name        = "jacobs_stepfunctions_events_policy"
  description = "Permissions required for ECS sync integrations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule",
        ]
        Resource = [
          "arn:aws:events:${var.region}:${local.account_id}:rule/StepFunctionsGetEventsForECSTaskRule",
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "jacobs_stepfunction_logs_policy" {
  name        = "jacobs_stepfunctions_logs_policy"
  description = "Permissions required for Step Functions log delivery"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment2" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_policy.arn
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment_cloudwatch_logs" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "jacobs_stepfunctions_role_attachment_eventbridge" {
  role       = aws_iam_role.jacobs_stepfunctions_role.name
  policy_arn = aws_iam_policy.jacobs_stepfunction_events_policy.arn
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
        "TaskDefinition": "${module.webscrape_ecs_module.ecs_task_definition_arn}",
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
        "TaskDefinition": "${module.dbt_ecs_module.ecs_task_definition_arn}",
        "NetworkConfiguration": {
            "AwsvpcConfiguration": {
                "SecurityGroups": ["${aws_security_group.jacobs_task_security_group_tf.id}"],
                "Subnets": ["${aws_subnet.jacobs_public_subnet.id}", "${aws_subnet.jacobs_public_subnet_2.id}"],
                "AssignPublicIp": "ENABLED"
            }
        }
      },
    "Next": "ml_pipeline",
          "Catch": [
            {
              "ErrorEquals": [
                "States.ALL"
              ],
              "Next": "ml_pipeline"
            }
          ]
        },
    "ml_pipeline": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${aws_ecs_cluster.jacobs_ecs_cluster.arn}",
        "TaskDefinition": "${module.ml_ecs_module.ecs_task_definition_arn}",
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
  description         = "Run every day at 12pm UTC"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "step_function_event_target" {
  target_id = "jacobs_stepfunctions_target"
  rule      = aws_cloudwatch_event_rule.step_functions_schedule.name
  arn       = aws_sfn_state_machine.jacobs_state_machine.arn
  role_arn  = aws_iam_role.jacobs_stepfunctions_event_role.arn
}
