import requests
import json
import boto3
import smtplib
import random
ssm = boto3.client('ssm', 'us-east-1')
client = boto3.client('sns')
cloudwatch = boto3.client('cloudwatch')

def put_metric(count):
    cloudwatch.put_metric_data(
        MetricData = [
            {
                'MetricName': 'Nodes count',
                'Dimensions': [
                    {
                        'Name': 'Nodes',
                        'Value': 'Count'
                    }
                ],
                'Unit': 'Count',
                'Value': count
            },
        ],
        Namespace = 'CoolApp'
    )
    return 0

def lambda_handler(event, context):
    try:
        url = "http://10.0.11.161:9200/_cluster/health?pretty=false"
        r = requests.get(url)
        y = json.loads(json.dumps(r.json()))
        put_metric(y["number_of_nodes"])
        return {
            'statusCode': 200,
            'body': json.dumps(r.status_code)
        }
    except:
        put_metric(0)
        return {
            'statusCode': 200,
            'body': json.dumps("not connection")
        }
