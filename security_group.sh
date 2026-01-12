#!/bin/bash
#
# This script lists all AWS EC2 security groups in the specified AWS region.

### variables
REGION="eu-central-1"
VPC_ID="vpc-0a9de6337ea6dd6c3"

### functions
create_ssh_security_group() {
    aws ec2 create-security-group \
        --group-name ssh-allow-all \
        --description "Allow SSH from anywhere" \
        --vpc-id "$VPC_ID" \
        --region "$REGION" \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=ssh-allow-all},{Key=Environment,Value=Dev}]'

    aws ec2 authorize-security-group-ingress \
        --group-name ssh-allow-all \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0 \
        --region "$REGION" \
        --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Purpose,Value=SSH},{Key=Owner,Value=Admin}]'
}

list_security_groups() {
    aws ec2 describe-security-groups \
        --region "$REGION" \
        --query 'SecurityGroups[].{ID:GroupId,Name:GroupName,VPC:VpcId}' \
        --output table
}

describe_security_group_rule() {
    aws ec2 describe-security-groups \
        --group-names "$security_group" \
        --region "$REGION" \
        --query 'SecurityGroups[].{Inbound:IpPermissions[].{Port:FromPort,Protocol:IpProtocol,Range:IpRanges[].CidrIp},Outbound:IpPermissionsEgress[].{Port:FromPort,Protocol:IpProtocol,Range:IpRanges[].CidrIp}}' \
        --output table
}

### command
option=$1
security_group=$2

if [ "$option" == "create" ]
then
    create_ssh_security_group
    exit 0
elif [ "$option" == "describe" ]
then
    if [ -z "$security_group" ]
    then
        echo "Please provide a security group name to describe."
        exit 1
    fi
    describe_security_group_rule
    exit 0
elif [ "$option" == "list" ]
then
    list_security_groups
    exit 0
fi




