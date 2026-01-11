#/bin/bash
#
# Administration of AWS S3 lifecycle policies.

### variables
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
ROLE_NAME="AWSDataLifecycleManagerDefaultRole"
EXECUTION_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"
DESCRIPTION="Snapshot Policy for EC2 Volume"

### functions
list_lifecycle_policies() {
    aws dlm get-lifecycle-policies --output table
}

create_lifecycle_policy() {
    aws dlm create-lifecycle-policy \
    --tags Name=DailySnapshotPolicy \
    --execution-role-arn $EXECUTION_ROLE_ARN \
    --description "$DESCRIPTION" \
    --state ENABLED \
    --policy-details '{
        "ResourceTypes":["VOLUME"],
        "TargetTags":[{"Key":"Snapshot","Value":"True"}],
        "Schedules":[{
           "Name":"DailySnapshots",
           "CopyTags":true,
           "TagsToAdd":[{"Key":"CreatedBy",
                        "Value":"DLM"}],
           "CreateRule":{"Interval":24,
                         "IntervalUnit":"HOURS",
                         "Times":["00:00"]},
           "RetainRule":{"Count":3}
        }]
    }'
}

### command
option=$1

if [ "$option" == "list" ]
then
    list_lifecycle_policies
elif [ "$option" == "create" ]
then
    create_lifecycle_policy
else
    echo "Usage: $0 {create|list}"
    exit 1
fi