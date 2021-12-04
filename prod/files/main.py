import json
import urllib.parse
import boto3
# from botocore.vendored import requests

print('Loading function')

s3 = boto3.client('s3')


def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        print("CONTENT TYPE: " + response['ContentType'])
        ###############################################
        # send curl request to trigger_dag('nba_elt_pipeline_qa') here
        ###############################################
        return response['ContentType']
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
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

