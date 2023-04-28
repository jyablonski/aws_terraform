import json
import urllib.parse
from datetime import datetime, timedelta

import boto3
from botocore.exceptions import ClientError

# from botocore.vendored import requests


def send_ses_email(input):
    SENDER = "jyablonski9@gmail.com"
    RECIPIENT = "jyablonski9@gmail.com"
    # CONFIGURATION_SET = "ConfigSet"
    AWS_REGION = "us-east-1"

    SUBJECT = f"{input} S3 FILE ARRIVED IN LAMBDA BUCKET at {datetime.now().strftime('%Y-%m-%d %I:%M:%S %p')}"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = f"{input} arrived in S3 Bucket"

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
        {input} arrived in S3 Bucket
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

s3 = boto3.client("s3")


def lambda_handler(event, context):
    """
    This function is used for direct S3 Bucket Event -> Lambda 
    """
    # print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        print("CONTENT TYPE: " + response["ContentType"])
        send_ses_email(key)
        ###############################################
        # send curl request to trigger_dag('nba_elt_pipeline_qa') here
        ###############################################
        return response["ContentType"]
    except Exception as e:
        print(e)
        print(
            "Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.".format(
                key, bucket
            )
        )
        raise e


###################
#                 #
#  AIRFLOW LAMBDA #
#                 #
###################
# def lambda_handler(event, context):
#     #print("Received event: " + json.dumps(event, indent=2))
#     try:
#         print("Event Passed to Handler: " + json.dumps(event))
#         data = {}
#         ###############################################
#         # send curl request to trigger_dag('nba_elt_pipeline_qa') here
#         url = 'http://ec2-xxx.us-east-2.compute.amazonaws.com:8080/api/experimental/dags/nba_elt_pipeline_qa/dag_runs'
#         print('sending POST request: ' + url)
#         r = requests.post(url, json.dumps(data))
#         print(f"response: {r}")
#         return r.status_code
#         ###############################################
#     except Exception as e:
#         print(f"An error occured: {e}")
#         raise e
