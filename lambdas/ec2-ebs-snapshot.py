import json
import boto3

SESSION = boto3.Session()
EC2 = SESSION.resource('ec2')


def get_volumes(ec2Id):

    instance = EC2.Instance(ec2Id)
    volumes = instance.volumes.all()
    volume_ids = [v.id for v in volumes]

    return volume_ids


def create_snapshot(volumeId):

    snapshot = EC2.create_snapshot(
        VolumeId=volumeId,
        TagSpecifications=[
            {
                'ResourceType': 'snapshot',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': 'forensic'
                    },
                ]
            },
        ]
    )

    snapshot.wait_until_completed()


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    instanceId = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    volumes = get_volumes(instanceId)
    for volume in volumes:
        print(volume)
        create_snapshot(volume)
