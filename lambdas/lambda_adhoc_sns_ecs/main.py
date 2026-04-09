from datetime import datetime

import boto3
import os

client = boto3.client("ecs")
ECS_CLUSTER_NAME = os.environ["ECS_CLUSTER_NAME"]
ECS_SECURITY_GROUP_ID = os.environ["ECS_SECURITY_GROUP_ID"]
ECS_SUBNET_IDS = os.environ["ECS_SUBNET_IDS"].split(",")


def lambda_handler(event, context):
    """
    Lambda Function which reads from an SNS Topic and reads in a task definition from the Message Body
    and runs it in ECS.

    The Task Definition must already be created by Terraform and exist in the us-east-1 jacobs_fargate_cluster.
    """
    # print(event) # do this initally for debugging bc how the fuq else do you see the layering of the nested event.
    try:
        for sns_event in event["Records"]:
            df = sns_event["Sns"]
            task_definition = df["Message"]

            response = client.run_task(
                taskDefinition=task_definition,
                launchType="FARGATE",
                cluster=ECS_CLUSTER_NAME,
                platformVersion="LATEST",
                count=1,
                networkConfiguration={
                    "awsvpcConfiguration": {
                        "securityGroups": [ECS_SECURITY_GROUP_ID],
                        "subnets": ECS_SUBNET_IDS,
                        "assignPublicIp": "ENABLED",
                    }
                },
            )
            print(response)

            print(
                f"Sending API Call to trigger ECS Task {task_definition} at {datetime.now()}"
            )
            return {"statusCode": 200, "body": "OK"}
    except BaseException as e:
        print(f"Error Occurred, {e}")
        raise e
