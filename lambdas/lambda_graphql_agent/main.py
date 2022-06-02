from datetime import datetime, timedelta
import json
import os

import boto3
from botocore.exceptions import ClientError
import pandas as pd

from sqlalchemy import exc, create_engine

def sql_connection(rds_schema: str):
    """
    SQL Connection function connecting to my postgres db with schema = nba_source where initial data in ELT lands.
    Args:
        rds_schema (str): The Schema in the DB to connect to.
    Returns:
        SQL Connection variable to a specified schema in my PostgreSQL DB
    """
    RDS_USER = os.environ.get("RDS_USER")
    RDS_PW = os.environ.get("RDS_PW")
    RDS_IP = os.environ.get("IP")
    RDS_DB = os.environ.get("RDS_DB")
    try:
        connection = create_engine(
            f"postgresql+psycopg2://{RDS_USER}:{RDS_PW}@{RDS_IP}:5432/{RDS_DB}",
            connect_args={"options": f"-csearch_path={rds_schema}"},
            # defining schema to connect to
            echo=False,
        )
        print(f"SQL Connection to schema: {rds_schema} Successful")
        return connection
    except exc.SQLAlchemyError as e:
        print(f"SQL Connection to schema: {rds_schema} Failed, Error: {e}")
        return e

def write_to_sql(con, table_name: str, df: pd.DataFrame, table_type: str):
    """
    SQL Table function to write a pandas data frame in aws_dfname_source format
    Args:
        con (SQL Connection): The connection to the SQL DB.
        table_name (str): The Table name to write to SQL as.
        df (DataFrame): The Pandas DataFrame to store in SQL
        table_type (str): Whether the table should replace or append to an existing SQL Table under that name
    Returns:
        Writes the Pandas DataFrame to a Table in Postgres in the {graphql} Schema that's been connected to.
    """
    try:
        if len(df) == 0:
            print(f"{table_name} is empty, not writing to SQL")
        else:
            df.to_sql(
                con=con,
                name=f"{table_name}",
                index=False,
                if_exists=table_type,
            )
            print(
                f"Writing {len(df)} {table_name} rows to {table_name} to SQL"
            )
    except BaseException as error:
        print(f"SQL Write Script Failed, {error}")
        return error

def get_messages_from_queue(queue_url):
    sqs_client = boto3.client('sqs')
    df = []
    messages = []

    while True:
        resp = sqs_client.receive_message(
            QueueUrl=queue_url,
            AttributeNames=['All'],
            MaxNumberOfMessages=10
        )

        try:
            messages.extend(resp['Messages'])
        except KeyError:
            print('There were no SQS Messages')
            break

        entries = [
            {'Id': msg['MessageId'], 'ReceiptHandle': msg['ReceiptHandle']}
            for msg in resp['Messages']
        ]

        resp = sqs_client.delete_message_batch(
            QueueUrl=queue_url, Entries=entries
        )

        if len(resp['Successful']) != len(entries):
            raise RuntimeError(
                f"Failed to delete messages: entries={entries!r} resp={resp!r}"
            )

        tot_messages = []
        tot_timestamps = []

        for msg in messages:
            msg_body = json.loads(msg['Body'])
            msg_text = msg_body['Message']
            msg_timestamp = msg_body['Timestamp']
            tot_messages.append(msg_text)
            tot_timestamps.append(msg_timestamp)

        if len(tot_messages) > 0:
            df = pd.DataFrame(
                {
                    "message": tot_messages,
                    "timestamp": tot_timestamps,
                }
            )
        else:
            print('There were no SQS Messages')

    return df

# from botocore.vendored import requests


print('Loading function')

def lambda_handler(event, context):
    """
    Lambda function that's triggered by EventBridge every 1 hr to read in and 
    """
    # print(event)
    try:
        graphql_queries = get_messages_from_queue(os.environ.get('SQS_URL'))
        conn = sql_connection('graphql')
        write_to_sql(conn, "graphql_queries", graphql_queries, "append")
    except BaseException as e:
        print(f"Error Occurred, {e}")
        df = []  # if you do raise e instead of this, lambda will keep retrying and using resources instead of just stopping.
        return df
