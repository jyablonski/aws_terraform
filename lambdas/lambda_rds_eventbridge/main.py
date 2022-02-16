import json
import urllib.parse
from datetime import datetime, timedelta
from typing import Dict

import boto3
from botocore.exceptions import ClientError

# from botocore.vendored import requests

def send_ses_email(event_category = "DEFAULT", event_type="DEFAULT", event_message="DEFAULT", event_time="DEFAULT", event_server = "DEFAULT", **kwargs):
    SENDER = "jyablonski9@gmail.com"
    RECIPIENT = "jyablonski9@gmail.com"
    # CONFIGURATION_SET = "ConfigSet"
    AWS_REGION = "us-east-1"

    SUBJECT = f"RDS Event at {event_time} - {event_message} for {event_server}"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = f"RDS Event at {event_time}, {kwargs} Category: {event_category}, Type: {event_type}, Message: {event_message}, Server: {event_server}"
                
    # The HTML body of the email.
    BODY_HTML = f"""<html>
    <head></head>
    <body>

    RDS Event at {event_time}
    <br>
    {kwargs}
    <br>
    Server: {event_server}
    <br>
    Category: {event_category}
    <br>
    Type: {event_type}
    <br>
    Message: {event_message}
    </body>
    </html>
                """            

    CHARSET = "UTF-8"
    client = boto3.client('ses',region_name=AWS_REGION)
    try:
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
            # ConfigurationSetName=CONFIGURATION_SET,
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

print('Loading function')

def lambda_handler(event, context):
    """
    Lambda Function to read RDS Events from an SNS Topic and send email out detailing events.
    """
    # print(event) # do this initally for debugging bc how the fuq else do you see the layering of the nested event.
    try:
        for rds_event in event['Records']:
            df = json.loads(rds_event['Sns']['Message'])['detail']
            event_category = df['EventCategories'][0]
            event_type = df['SourceType']
            event_message = df['Message']
            event_time = df['Date']
            event_server = df['SourceIdentifier']

            send_ses_email(event_category, event_type, event_message, event_time, event_server)
            print(f"Sending SES Email")
    except BaseException as e:
        print(f"Error Occurred, {e}")
        send_ses_email(kwargs=e)
        df = []  # if you do raise e instead of this, lambda will keep retrying and using resources instead of just stopping.
        return df
