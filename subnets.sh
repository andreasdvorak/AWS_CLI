#/bin/bash
#
# Administration AWS EC2 subnets in the specified AWS region.

### variables
REGION="eu-central-1"
VPC_ID="vpc-0a9de6337ea6dd6c3"

### functions
list_subnets() {
    aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --region $REGION \
        --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,State:State}' \
        --output table
}

show_route() {
    echo "subnet | name | cidr | az | type"
    for subnet in $(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --region $REGION \
        --query 'Subnets[].SubnetId' \
        --output text); do
        name=$(aws ec2 describe-subnets \
            --subnet-ids $subnet \
            --region $REGION \
            --query 'Subnets[0].Tags[?Key==`Name`].Value | [0]' \
            --output text)
        az=$(aws ec2 describe-subnets \
            --subnet-ids $subnet \
            --region $REGION \
            --query 'Subnets[0].AvailabilityZone' \
            --output text)
        cidr=$(aws ec2 describe-subnets \
            --subnet-ids $subnet \
            --region $REGION \
            --query 'Subnets[0].CidrBlock' \
            --output text)
        route=$(aws ec2 describe-route-tables \
            --filters "Name=association.subnet-id,Values=$subnet" \
            --region $REGION \
            --query 'RouteTables[].Routes[?GatewayId!=null].GatewayId' \
            --output text)
        if [[ -n "$route" ]]; then
            type="Public"
        else
            type="Private"
        fi
        echo "$subnet | $name | $cidr | $az | $route | $type"
    done
}

### command
option=$1

if [ "$option" == "list" ]
then
    list_subnets
    exit 0
elif [ "$option" == "route" ]
then
    show_route
    exit 0
else
    echo "Usage: $0 {list|route}"
    exit 1
fi
