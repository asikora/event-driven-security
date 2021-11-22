import json
import boto3


def sg_revoke_rule(groupId, ipPermissions):
    session = boto3.Session()
    ec2 = session.client('ec2')
    ec2.revoke_security_group_ingress(
        GroupId=groupId, IpPermissions=ipPermissions)


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    groupId = event["detail"]["requestParameters"]["groupId"]
    ipPermissionsItems = event["detail"]["requestParameters"]["ipPermissions"]["items"]
    print("Security group id: " + groupId)
    for ipPermissionsItem in ipPermissionsItems:
        ipPermissions = [{
            "IpProtocol": ipPermissionsItem["ipProtocol"],
            "FromPort": ipPermissionsItem["fromPort"],
            "ToPort": ipPermissionsItem["toPort"],
            "IpRanges": []
        }]
        for ipRanges in ipPermissionsItem["ipRanges"]["items"]:
            print(ipRanges)
            cidr = {
                "CidrIp": ipRanges["cidrIp"]
            }
            ipPermissions[0]["IpRanges"].append(cidr)
        if ipPermissions[0]["FromPort"] == 22 and ipPermissions[0]["ToPort"] == 22:
            sg_revoke_rule(groupId, ipPermissions)
