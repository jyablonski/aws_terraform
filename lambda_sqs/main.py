from datetime import datetime, timedelta
import json
import urllib.parse
import boto3
from botocore.exceptions import ClientError
# from botocore.vendored import requests

def send_ses_email(s3_key, s3_bucket):
    SENDER = "jyablonski9@gmail.com"
    RECIPIENT = "jyablonski9@gmail.com"
    # CONFIGURATION_SET = "ConfigSet"
    AWS_REGION = "us-east-1"

    SUBJECT = f"{s3_key} S3 FILE ARRIVED IN {s3_bucket} at {datetime.now().strftime('%Y-%m-%d %I:%M:%S %p')}"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = f"{s3_key} arrived in {s3_bucket}"
                
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
        {s3_key} arrived in {s3_bucket}
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
    SQS Lambda Function - DIFFERENT FORMAT FROM S3 NOTIFICATIONS
    The S3 notification code in inside ['body'] of the SQS Message
    """
    try:
        for sqs_event in event['Records']:
            # print(sqs_event) use this for debugging this bs
            s3_event = json.loads(sqs_event['body'])
            if 'Event' in s3_event.keys() and s3_event['Event'] == 's3:TestEvent':
                print('LOADED TEST EVENT - EXITING')
                break
            for s3_record in s3_event['Records']:
                key = s3_record['s3']['object']['key']
                print(f"Grabbing Key {key}")

                bucket = s3_record['s3']['bucket']['name']
                print(f"Grabbing Bucket {bucket}")
                
                send_ses_email(key, bucket)
                print(f"Sending SES Email")
    except Exception as e:
        print(f"Error Occurred, {e}")
        raise e
