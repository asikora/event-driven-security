import json
import boto3

SESSION = boto3.Session()
EC2 = SESSION.resource('ec2')


def tag_resource(ec2Id, eventId):
    EC2.create_tags(Resources=[ec2Id], Tags=[
        {
            "Key": "Enviroment",
            "Value": "Quarantine: " + eventId
        }])


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    instanceId = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    eventId = event["id"]
    tag_resource(instanceId, eventId)
