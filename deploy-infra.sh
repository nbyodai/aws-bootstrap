#!/bin/bash

AWS_ACCOUNT_IS-`aws sts get-caller-identity --profile awsbootsrap --query "Account" --output text`
CODEPIPELINE="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"
STACK_NAME=awsbootstrap
REGION=us-east-2
CLI_PROFILE=awsbootstrap

EC2_INSTANCE_TYPE=t2.micro

# Deploys static resources
echo -e "\n\n========== Deploying setup.yml =========="
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME-setup \
  --template-file setup.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EC2InstanceType=$EC2_INSTANCE_TYPE

echo -e "\n\n========== Deploying main.yml =========="
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME-setup \
  --template-file main.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EC2InstanceType=$EC2_INSTANCE_TYPE

# If the deploy succeeded, show the DNS name of the created instance
if [ $? -eq 0 ]; then
  aws cloudformation list-exports \
    --profile awsbootstrap \
    --query "Exports[?Name=='InstanceEndpoint'].Value"
fi
