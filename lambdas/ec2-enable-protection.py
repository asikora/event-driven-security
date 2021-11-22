import json
import boto3

SESSION = boto3.Session()
EC2 = SESSION.resource('ec2')


def enable_termination_protection(ec2Id):
    EC2.Instance(ec2Id).modify_attribute(
        DisableApiTermination={
            'Value': True
        })


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    instanceId = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    enable_termination_protection(instanceId)
