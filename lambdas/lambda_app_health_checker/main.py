import json
import os

import requests

API_ENDPOINT = "https://api.jyablonski.dev"
DASHBOARD_ENDPOINT = "https://nbadashboard.jyablonski.dev"


def write_to_slack(error: str, webhook_url: str = os.environ.get("WEBHOOK_URL")):
    try:
        response = requests.post(
            webhook_url,
            data=json.dumps({"text": f"Data Product issue detected: {error}"}),
            headers={"Content-Type": "application/json"},
        )
    except BaseException as e:
        print(f"Error sending message to Slack: {e}")
        pass


def lambda_handler(event, context):
    """
    Lambda function that's triggered by EventBridge every 1 hr to check
    the status of the API and Dashboard.
    """
    api_request = requests.get(API_ENDPOINT)
    dashboard_request = requests.get(DASHBOARD_ENDPOINT)

    status_codes = {
        "rest_api": api_request.status_code,
        "dashboard": dashboard_request.status_code,
    }

    if not all(status_code == 200 for status_code in status_codes.values()):
        errors = ", ".join(
            [
                f"{key} is returning a {value} Error"
                for key, value in status_codes.items()
                if value != 200
            ]
        )
        write_to_slack(errors, webhook_url=os.environ.get("WEBHOOK_URL"))
    else:
        print("All status codes are 200!")
        return
