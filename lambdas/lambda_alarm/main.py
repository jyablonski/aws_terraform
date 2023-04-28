import json
import logging
import os
import sys

sys.path.insert(0, "package/")

import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def parse_service_event(event, timestamp, service="Service"):
    return [
        {"name": service, "value": event["Trigger"]["MetricName"], "inline": True},
        {"name": "alarm", "value": event["AlarmName"], "inline": True},
        {"name": "description", "value": event["AlarmDescription"], "inline": True},
        {"name": "oldestState", "value": event["OldStateValue"], "inline": True},
        {"name": "trigger", "value": event["Trigger"]["MetricName"], "inline": True},
        {"name": "event", "value": event["NewStateReason"], "inline": True},
        {"name": "timestamp", "value": timestamp, "inline": True},
    ]


def lambda_handler(event, context):
    for record in event["Records"]:
        logging.info(f"Record is {record}")
        timestamp = record["Sns"]["Timestamp"]
        sns_message = record["Sns"]["Message"]
        is_alarm = sns_message["Trigger"]
        parsed_message = parse_service_event(sns_message, timestamp, "Lambda")
        logging.info(f"Parsed Message is {parsed_message}")

        discord_data = {
            "username": "ALARM WEBHOOK",
            "avatar_url": "https://a0.awsstatic.com/libra-css/images/logos/aws_logo_smile_1200x630.png",
            "embeds": [
                {
                    "author": {
                        "name": "ALARM_TRIGGER♫",
                        "icon_url": "https://i.imgur.com/R66g1Pe.jpg",
                    },
                    "color": 16711680,
                    "fields": parsed_message,
                    "footer": {
                        "text": "See a bug?  Pls message Jacob",
                        "icon_url": "https://i.imgur.com/fKL31aD.jpg",
                    },
                }
            ],
            "content": "<@95723063835885568>",
        }

        headers = {"content-type": "application/json"}
        response = requests.post(
            os.environ.get("WEBHOOK_URL"),
            data=json.dumps(discord_data),
            headers=headers,
        )

        logging.info(f"Discord response: {response.status_code}")
        logging.info(response.content)
