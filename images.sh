#!/bin/bash
#
# This script lists all images.

### variables
REGION="eu-central-1"
IMAGE_FILTER="amzn2-ami-hvm-*-x86_64-gp2"
OWNER="137112412989"
#IMAGE_FILTER="debian-13*-amd64-*"
#OWER="136693071363"


### command
aws ec2 describe-images \
    --owners ${OWNER} \
    --region ${REGION} \
    --filters "Name=name,Values=${IMAGE_FILTER}" \
    --query "Images[*].[ImageId,Name]" \
    --output table
