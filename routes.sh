#/bin/bash
#
# Administration AWS routes in the specified AWS region.

### variables
REGION="eu-central-1"
VPC_ID="vpc-0a9de6337ea6dd6c3"

### functions
list_routes() {
    aws ec2 describe-route-tables --output table
}

### command
option=$1

if [ "$option" == "list" ]
then
    list_routes
    exit 0
else
    echo "Usage: $0 {list}"
    exit 1
fi
