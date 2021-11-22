import json
import boto3
import os

SESSION = boto3.Session()
EC2 = SESSION.resource('ec2')
SG_DENYALL = os.environ['SG_DENYALL']


def change_sg(ec2Id):
    EC2.Instance(ec2Id).modify_attribute(
        Groups=[SG_DENYALL]
    )


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    instanceId = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    change_sg(instanceId)
