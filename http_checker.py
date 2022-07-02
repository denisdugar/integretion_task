import requests
import json
import boto3
import smtplib
ssm = boto3.client('ssm', 'us-east-1')
client = boto3.client('sns')

def get_parameters():
    response = ssm.get_parameters(
        Names=['parametr'],WithDecryption=False
    )
    for parameter in response['Parameters']:
        return parameter['Value']
def put_parameter(param):
    ssm.put_parameter(
                Name='/parametr',
                Value=param,
                Type='String',
                Overwrite=True
            )
    return 0
def send_message(message):
    response = client.publish(
                TargetArn='arn:aws:sns:us-east-1:328584161733:http_checker_error',
                Message=message,
                MessageStructure='string'
            )
    return 0

def lambda_handler(event, context):
    try:
        url = "http://1111/_cluster/health?pretty=false"
        r = requests.get(url)
        y = json.loads(json.dumps(r.json()))
        if y["number_of_nodes"] == 6:
            put_parameter('0')
            return {
                'statusCode': 200,
                'body': json.dumps(r.status_code)
            }
        else:
            value = get_parameters()
            a = int(value) + 1
            put_parameter(str(a))
            if a == 3:
                send_message('Site is down')
                put_parameter('0')
            return {
                'statusCode': 200,
                'body': json.dumps("error code")
            }
    except:
        value = get_parameters()
        a = int(value) + 1
        put_parameter(str(a))
        if a >= 3:
            send_message('Site is down')
            put_parameter('0')
        return {
            'statusCode': 200,
            'body': json.dumps("error cant connect")
            }
