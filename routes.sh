#!/bin/bash
#
# Administration AWS routes in the specified AWS region.

### variables

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
