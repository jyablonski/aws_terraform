import json
import urllib.parse
from datetime import datetime, timedelta
from typing import Dict

import boto3
from botocore.exceptions import ClientError

# from botocore.vendored import requests


def send_ses_email(event_message="DEFAULT", event_timestamp="DEFAULT", **kwargs):
    SENDER = "jyablonski9@gmail.com"
    RECIPIENT = "jyablonski9@gmail.com"
    # CONFIGURATION_SET = "ConfigSet"
    AWS_REGION = "us-east-1"

    SUBJECT = f"AD HOC SNS EVENT TRIGGERED at {event_timestamp}"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = f"AD HOC SNS EVENT TRIGGERED {event_message}"

    # The HTML body of the email.
    BODY_HTML = f"""<html>
    <head></head>
    <body>

    Ad Hoc SNS Event at {event_timestamp}
    <br>
    <br>
    Message: {event_message}
    </body>
    </html>
                """

    CHARSET = "UTF-8"
    client = boto3.client("ses", region_name=AWS_REGION)
    try:
        response = client.send_email(
            Destination={"ToAddresses": [RECIPIENT,],},
            Message={
                "Body": {
                    "Html": {"Charset": CHARSET, "Data": BODY_HTML,},
                    "Text": {"Charset": CHARSET, "Data": BODY_TEXT,},
                },
                "Subject": {"Charset": CHARSET, "Data": SUBJECT,},
            },
            Source=SENDER,
            # ConfigurationSetName=CONFIGURATION_SET,
        )
    except ClientError as e:
        print(e.response["Error"]["Message"])
    else:
        print("Email sent! Message ID:"),
        print(response["MessageId"])


print("Loading function")


def lambda_handler(event, context):
    """
    Lambda Function to read RDS Events from an SNS Topic and send email out detailing events.

    The event_message variable is how you extract the raw message out of the SNS Notification.

    In the future, i want to send a task_definition name in the message and then use this lambda to trigger ECS Tasks
    """
    # print(event) # do this initally for debugging bc how the fuq else do you see the layering of the nested event.
    try:
        for sns_event in event["Records"]:
            df = sns_event["Sns"]
            event_message = df["Message"]
            event_timestamp = df["Timestamp"]

            send_ses_email(event_message, event_timestamp)
            print(f"Sending SES Email")
    except BaseException as e:
        print(f"Error Occurred, {e}")
        send_ses_email(kwargs=e)
        df = (
            []
        )  # if you do raise e instead of this, lambda will keep retrying and using resources instead of just stopping.
        return df
