#/bin/bash
#
# Administration of AWS EC2 key pair.
# The key pair is created in the specified AWS region.
# The key pair can be by anyone who has access to the pem file.

### variables
KEY_NAME="MyKeyPair"
REGION="eu-central-1"
OUTPUT_FILE="${KEY_NAME}_${REGION}.pem"

### functions
create_key_pair() {
    if [ -f "$OUTPUT_FILE" ]; then
        echo "Key pair file $OUTPUT_FILE already exists. Exiting."
        exit 1
    fi

    aws ec2 create-key-pair \
        --region $REGION \
        --key-name $KEY_NAME \
        --query 'KeyMaterial' \
        --output text > $OUTPUT_FILE
    
    chmod 400 $OUTPUT_FILE
    echo "Key pair $KEY_NAME created and saved to $OUTPUT_FILE"
}

list_key_pairs() {
    aws ec2 describe-key-pairs --output table
}

### command

option=$1

if [ "$option" == "create" ]
then
    create_key_pair
elif [ "$option" == "list" ]
then
    list_key_pairs
else
    echo "Usage: $0 {create|list}"
    exit 1
fi
