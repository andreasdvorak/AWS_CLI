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

File are created here

~/.aws

## Test
Test the connection
```
aws iam list-users
```

# Linter
Installation of shellcheck
```
sudo apt-get install shellcheck
```

Run shellcheck
```
shellcheck *.sh
```