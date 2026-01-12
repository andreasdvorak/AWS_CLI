#/bin/bash
#
# This script lists all AWS virtual private clouds (VPCs) in the specified AWS region.

### variables
REGION="eu-central-1"
VPC_ID="vpc-0a9de6337ea6dd6c3"
KEY_PAIR="MyKeyPair"
SECURITY_GROUP_ID="sg-007c4d152a6a96ad6 sg-03440fa427203b731"
SUBNET_ID="subnet-0123456789abcdef0"
INSTANCE_TYPE="t3.micro"
IMAGE_ID="ami-0387413ed05eb20af"
TAG_NAME="MyEC2Instance" 
TAG_ROLE="WebServer"
IMAGE_FILTER="amzn2-ami-hvm-*-x86_64-gp2"
TAG_SNAPSHOT="true"

### functions
create_instance() {
    echo "Creating EC2 instance..."

    aws ec2 run-instances \
        --image-id ${IMAGE_ID} \
        --instance-type ${INSTANCE_TYPE} \
        --key-name ${KEY_PAIR} \
        --count 1 \
        --security-group-ids ${SECURITY_GROUP_ID} \
        --region ${REGION} \
        --instance-initiated-shutdown-behavior stop \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value='${TAG_NAME}'}, \
                                                        {Key=Role,Value='${TAG_ROLE}'}, \
                                                        {Key=Snapshot,Value='${TAG_SNAPSHOT}'}]" \
                            "ResourceType=volume,Tags=[{Key=Name,Value='${TAG_NAME}-root'}, \
                                                        {Key=Snapshot,Value='${TAG_SNAPSHOT}'}]" \
                            "ResourceType=network-interface,Tags=[{Key=Name,Value='${TAG_NAME}-eni'}]" \
        >> ${TAG_NAME}_instance_launch.log
}

get_instance_id() {
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${TAG_NAME}" \
        --region ${REGION} \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)
    echo ${INSTANCE_ID}
}

list_instances() {
    echo "Listing EC2 instances..."

    aws ec2 describe-instances \
        --region ${REGION} \
        --filters "Name=tag:Name,Values=${TAG_NAME}" \
        --query 'Reservations[].Instances[].{ID:InstanceId,
                                             Type:InstanceType,
                                             State:State.Name,
                                             AZ:Placement.AvailabilityZone,
                                             PublicIP:PublicIpAddress,
                                             PrivateIP:PrivateIpAddress}' \
        --output table
}

get_status() {
    echo "Getting EC2 instance status..."

    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${TAG_NAME}" \
        --region ${REGION} \
        --query "Reservations[].Instances[].{ID:InstanceId,
                                             State:State.Name,
                                             AZ:Placement.AvailabilityZone,
                                             PublicIP:PublicIpAddress,
                                             PrivateIP:PrivateIpAddress,
                                             Type:InstanceType,
                                             Tags:Tags}" \
        --output table
}

terminate_instance() {
    INSTANCE_ID=$(get_instance_id)

    if [ -z "${INSTANCE_ID}" ]; then
        echo "No instance found with the name ${TAG_NAME}."
        return
    fi

    echo "Terminating EC2 instance ${INSTANCE_ID}..."

    aws ec2 terminate-instances \
        --instance-ids ${INSTANCE_ID} \
        --region ${REGION} \
        >> ${TAG_NAME}_instance_termination.log
}   

### command
option=$1

if [ "$option" == "create" ]; then
    create_instance
    exit 0
elif [ "$option" == "list" ]; then
    list_instances
    exit 0
elif [ "$option" == "status" ]; then
    get_status
    exit 0
elif [ "$option" == "terminate" ]; then
    terminate_instance
    exit 0
else
    echo "Usage: $0 {create|list|status|terminate}"
    exit 1
fi
