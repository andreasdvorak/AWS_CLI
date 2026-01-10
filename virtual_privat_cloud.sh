#/bin/bash
#
# This script lists all AWS virtual private clouds (VPCs) in the specified AWS region.

### variables
REGION="eu-central-1"

### command
aws ec2 describe-vpcs \
    --region $REGION \
    --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}' \
    --output table
