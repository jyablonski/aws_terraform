import json
import urllib.parse
from datetime import datetime, timedelta

import boto3
from botocore.exceptions import ClientError

# Deactiviating as of 2022-07-12 - lambda subscribed to sqs makes it poll 1000s of times a month.
# from botocore.vendored import requests

def send_ses_email(s3_key="DEFAULT", s3_bucket="DEFAULT", s3_event_time="DEFAULT", kwargs = ""):
    SENDER = "jyablonski9@gmail.com"
    RECIPIENT = "jyablonski9@gmail.com"
    # CONFIGURATION_SET = "ConfigSet"
    AWS_REGION = "us-east-1"

    SUBJECT = f"{s3_key} S3 FILE ARRIVED IN {s3_bucket} at {s3_event_time}"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = f"{kwargs}{s3_key} arrived in {s3_bucket} at {s3_event_time}"
                
    # The HTML body of the email.
    BODY_HTML = f"""<html>
    <head></head>
    <body>
    <h1>Amazon SES Test (SDK for Python)</h1>
    <p>This email was sent with
        <a href='https://aws.amazon.com/ses/'>Amazon SES</a> using the
        <a href='https://aws.amazon.com/sdk-for-python/'>
        AWS SDK for Python (Boto)</a>.</p>
        <br>
        {s3_key} arrived in {s3_bucket} at {s3_event_time}
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

s3 = boto3.client('s3')


def lambda_handler(event, context):
    """
    SQS Lambda Function - Format is S3 -> SNS -> SQS -> Lambda.
    The S3 notification code in inside ['body']['Message']
    The for loops are to iterate throguh dict lists (elements 0, 1, 2), instead of going event['Records'][0]
    """
    # print(event)
    try:
        for s3_event in event['Records']:
            df = json.loads(json.loads(s3_event['body'])['Message'])
            for s3_record in df['Records']:
                bucket = s3_record['s3']['bucket']['name']
                print(f"Grabbing Bucket {bucket}")

                key = s3_record['s3']['object']['key']
                print(f"Grabbing key {key}")

                event_time = s3_record['eventTime']
                print(f"Grabbing event time {event_time}")

                send_ses_email(key, bucket, event_time)
                print(f"Sending SES Email")
    except BaseException as e:
        print(f"Error Occurred, {e}")
        send_ses_email(kwargs=e)
        df = []  # if you do raise e instead of this, lambda will keep retrying and using resources instead of just stopping.
        return df
