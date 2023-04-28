from datetime import datetime, timedelta
import json
import os

import boto3
import pandas as pd
import requests
from sqlalchemy import exc, create_engine


def write_to_slack(message: str, webhook_url: str = os.environ.get("webhook_url")):
    try:
        requests.post(
            webhook_url,
            data=json.dumps({"text": message}),
            headers={"Content-Type": "application/json"},
        )
    except BaseException as e:
        raise e(f"Error Occurred w/ Slack Function, {e}")


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
    RDS_IP = os.environ.get("RDS_HOST")
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
                con=con, name=f"{table_name}", index=False, if_exists=table_type,
            )
            print(f"Writing {len(df)} {table_name} rows to {table_name} to SQL")
    except BaseException as error:
        print(f"SQL Write Script Failed, {error}")
        return error


def get_rds_metrics(client, rds_server: str, period: int, start_time: datetime):
    print(f"start_time is {start_time}, end_time is {(start_time - timedelta(days=1))}")
    response = client.get_metric_data(
        MetricDataQueries=[
            {
                "Id": "cpu_utilization",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "CPUUtilization",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "freeable_memory",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "FreeableMemory",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "db_connections",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "DatabaseConnections",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "write_iops",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "WriteIOPS",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "read_iops",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "ReadIOPS",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "deadlocks",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "Deadlocks",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "network_throughput",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "NetworkThroughput",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "read_latency",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "ReadLatency",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
            {
                "Id": "write_latency",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/RDS",
                        "MetricName": "WriteLatency",
                        "Dimensions": [
                            {"Name": "DBInstanceIdentifier", "Value": rds_server}
                        ],
                    },
                    "Period": period,
                    "Stat": "Average",
                },
            },
        ],
        StartTime=(start_time - timedelta(days=1)).timestamp(),
        EndTime=start_time.timestamp(),
    )
    df = pd.DataFrame(response["MetricDataResults"])
    df = df.explode(["Timestamps", "Values"]).reset_index()
    df["database"] = rds_server
    df = df.drop(["index", "Id", "StatusCode"], axis=1)

    print(f"Acquired {len(df)} Records, returning DataFrame")
    return df


print("Loading function")


def lambda_handler(event, context):
    """
    Lambda function that's triggered by EventBridge every 12 hrs to process SQS Messages for the GraphQL API.
    """
    # print(event)
    try:
        today = datetime.now()
        client = boto3.client("cloudwatch")

        metrics = get_rds_metrics(client, "jacobs-rds-server", 60, today)
        conn = sql_connection("nba_source")
        write_to_sql(conn, "aws_cloudwatch_metrics", metrics, "append")
    except BaseException as e:
        print(f"Error Occurred, {e}")
        write_to_slack(e)
        raise e
