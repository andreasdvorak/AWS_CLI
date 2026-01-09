#/bin/bash
#
# This script creates an AWS EC2 key pair and saves the private key to a file.
# The key pair is created in the specified AWS region.
# The key pair can be by anyone who has access to the pem file.

### variables
KEY_NAME="MyKeyPair"
REGION="eu-central-1"
OUTPUT_FILE="${KEY_NAME}_${REGION}.pem"

### command
aws ec2 create-key-pair \
    --region $REGION \
    --key-name $KEY_NAME \
    --query 'KeyMaterial' \
    --output text > $OUTPUT_FILE

chmod 400 $OUTPUT_FILE