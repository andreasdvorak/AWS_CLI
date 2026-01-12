#!/bin/bash
# Administration of AWS EC2 snapshots
#

### variables
REGION="eu-central-1"

### functions
list_snapshots() {
    echo "Listing EC2 snapshots..." 
    aws ec2 describe-snapshots \
        --region "${REGION}" \
        --filters "Name=tag:Name,Values=${snapshot_name}" \
        --owner-ids self \
        --query 'Snapshots[].{ID:SnapshotId,
                             VolumeID:VolumeId,
                             State:State,
                             StartTime:StartTime,
                             Description:Description}' \
        --output table
}

delete_snapshot() {
    SNAPSHOT_ID=$1

    if [ -z "${SNAPSHOT_ID}" ]; then
        echo "No snapshot ID provided."
        return
    fi

    echo "Deleting EC2 snapshot ${SNAPSHOT_ID}..."

    aws ec2 delete-snapshot \
        --snapshot-id "${SNAPSHOT_ID}" \
        --region "${REGION}" \
        >> snapshot_deletion.log
}

### command
option=$1
snapshot_name=$2

if [ "$option" == "list" ]; then
    list_snapshots
    exit 0
elif [ "$option" == "delete" ]; then
    delete_snapshot "$2"
    exit 0
else
    echo "Usage: $0 {list <NAME>|delete <SNAPSHOT_ID>}"
    exit 1
fi