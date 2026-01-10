#/bin/bash
#
# Administration AWS EC2 subnets in the specified AWS region.

### variables
REGION="eu-central-1"
VPC_ID="vpc-0a9de6337ea6dd6c3"

### functions
activate_map-public-ip-on-launch() {
    echo "Activating MapPublicIpOnLaunch for subnet $subnet_id..."

    aws ec2 modify-subnet-attribute \
        --subnet-id $subnet_id \
        --map-public-ip-on-launch \
        --region $REGION
}

deactivate_map-public-ip-on-launch() {
    echo "Deactivating MapPublicIpOnLaunch for subnet $subnet_id..."

    aws ec2 modify-subnet-attribute \
        --subnet-id $subnet_id \
        --no-map-public-ip-on-launch \
        --region $REGION
}

list_subnets() {
    aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --region $REGION \
        --query 'Subnets[].{ID:SubnetId,
                            CIDR:CidrBlock,
                            AZ:AvailabilityZone,
                            State:State,
                            PublicIP:MapPublicIpOnLaunch}' \
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
subnet_id=$2

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
