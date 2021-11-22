import json
import boto3
import os

S3_BUCKET = os.environ['S3_BUCKET']
SESSION = boto3.Session()


def capture_metadata(ec2Id):
    ec2 = SESSION.client('ec2')
    metadata = ec2.describe_instances(InstanceIds=[ec2Id])
    return metadata


def save_to_s3_bucket(key, data):
    s3 = SESSION.client('s3')
    s3.put_object(Body=json.dumps(data, indent=4, sort_keys=True, default=str), Bucket=S3_BUCKET,
                  Key=key + '/metadata.json')


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    instanceId = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    data = capture_metadata(instanceId)
    save_to_s3_bucket(instanceId, data)
