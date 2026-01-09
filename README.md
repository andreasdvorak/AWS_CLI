# AWS CLI
This is an introduction to the AWS CLI.

# AWS user
It is recommended to create a service account.

IAM -> user -> add user

Download the csv file with the credentials.

# AWS Cli
## Installation
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

## Configuration
For the configuration you need you credential details
```
aws configure
```

## Test
Test the connection
```
aws iam list-users
```


------------


# Role to set up the AWS configuration
It installs the AWS cli.

The scripts for the administration of AWS instances can be found in the directory /aws.

The AWS credentials file needs to be copied manually to /root/.aws. 

# aws cli
## Get Image ID
The Owner-ID 679593333241 belongs to the official AlmaLinux-AMI publisher.
```
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=AlmaLinux OS 9*" --query "Images[*].[ImageId,Name]"
```

Describe image by id
```
aws ec2 describe-images --image-ids ami-040588271d86b8ae3 \
--query "Images[*].[ImageId,Name,Description,CreationDate,Architecture,Platform]"
```

# AWS subnet
We use the following subnet subnet-5d7b6210

Show details to subnet
```
aws ec2 describe-subnets --subnet-ids subnet-5d7b6210
```
Netmask: 255.255.240.0

first ip: 172.31.0.1

last ip: 172.31.15.254

number of ips: 4094

Show attributes
```
aws ec2 describe-subnets \
    --subnet-ids subnet-5d7b6210 \
    --query "Subnets[*].[SubnetId,MapPublicIpOnLaunch]"
```
IF MapPublicIpOnLaunch = True, the subnet is configured that instanzes get a public ip.

The public IP is not configured in the instance, but outsite in AWS.



# AWS Instance type

```
aws ec2 describe-instances \
    --instance-ids i-0ce36bc4f2dec7828 \
    --query "Reservations[*].Instances[*].InstanceType" \
    --output text
```

# AWS Key Pair Name
The Key Pair is AWS specific and is configured in the EC2 console unter Key Pairs.
```
aws ec2 describe-instances \
    --instance-ids i-0ce36bc4f2dec7828 \
    --query "Reservations[*].Instances[*].KeyName" \
    --output text
```

ssh -i MeinSSHKey.pem ec2-user@<Public-IP>

The public key is in home/ec2-user/.ssh/authorized_keys

## Creation of key pair

```
aws ec2 create-key-pair \
    --key-name ec2_20251216 \
    --query 'KeyMaterial' > ec2_privat_key.pem
```

Show public key
```
aws ec2 describe-key-pairs \
    --key-names MeinSSHKey \
    --query "KeyPairs[*].PublicKey" \
    --output text
```

# AWS admin script
## Usage of the scripts
Run the scripts with sudo

## List instance
List instances 
```
sudo ./instance_adminstration.sh --action list
```

## Create instance
ImageID: ami-06e30f75e86156c53
Description: AlmaLinux OS 9.7.20251118 x86_64-3c74c2ba-21a2-4dc1-a65d-fd0ee7d79900

Put your public key in the file ansible_user_setup.sh at <key>. This script is automatically run after the creatation of the instance.

The instance name should be the same as the hostname.
 
```
sudo ./instance_adminstration.sh --action create --instance_name <hostname> --instance_tag_function <tag_function_of_instance>
./instance_adminstration.sh --action create --instance_name <hostname> --instance_type <type of instance> --instance_tag_contact "<tag name of contact>" --instance_tag_role <tag_function_of_role> --instance_tag_uptime <permanent|parttime>
```

Details for EC2 instances https://aws.amazon.com/ec2/pricing/on-demand/

If an instance needs an Elastic IP, you need to 

## Login as ec2-user
Login as ec2-user. That user is automatically created by AWS.

```
ssh -i /aws/BE-DEV-KEY9.pem ec2-user@<PrivateIpAddresses>
```

## Update inventory
Add the host to the Ansible inventory.

## Run ansible
Follow the README in the main directory.

# AWS EC2 Scripts
More ec2 scripts can be found here.

https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/aws-cli/bash-linux/ec2

# Autoscaling
Show auto scaling groups
```
aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].AutoScalingGroupName"
```

Show details for a asg_name
```
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names <ASG_NAME>
```

