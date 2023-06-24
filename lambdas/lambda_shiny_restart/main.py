from datetime import datetime
import json
import os

import boto3
import requests

def write_to_slack(error: str, webhook_url: str = os.environ.get("WEBHOOK_URL")):
    try:
        response = requests.post(
            webhook_url,
            data=json.dumps({"text": f"Lambda Function Shiny Restart Failed, {error}"}),
            headers={"Content-Type": "application/json"},
        )
    except:
        pass


def lambda_handler(event, context):
    print(f"Starting Lambda Shiny Restart at {datetime.now()}")
    try:
        client = boto3.client("ecs")
        cluster_name = os.environ.get("ECS_EC2_CLUSTER")

        response = client.list_tasks(
            cluster=cluster_name,
        )
        task_id = response['taskArns'][0]

        response = client.stop_task(
            cluster=cluster_name,
            task=task_id,
        )
        print(f"Successfully stopped Shiny Dashboard Task, exiting at {datetime.now()}...")
    except BaseException as e:
        write_to_slack(e)
