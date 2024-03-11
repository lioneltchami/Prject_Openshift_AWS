#!/bin/bash

# Configure AWS credentials

# Prompt the user for AWS access key ID
read -rp "Enter your AWS access key ID: " aws_access_key_id

# Prompt the user for AWS secret access key
read -rp "Enter your AWS secret access key: " aws_secret_access_key

# Write the AWS credentials to the ~/.aws/credentials file
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = $aws_access_key_id
aws_secret_access_key = $aws_secret_access_key
EOF

# Provide feedback to the user
echo "AWS credentials have been saved to ~/.aws/credentials."

# Initialize Terraform
terraform init

# Validate and plan the Terraform configuration
terraform validate && terraform plan -out=plan.out

# Apply Terraform configuration
terraform apply --auto-approve "plan.out"
