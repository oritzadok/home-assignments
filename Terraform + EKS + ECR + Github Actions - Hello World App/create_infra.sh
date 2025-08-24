#!/bin/bash

cd terraform/backend/
terraform init
terraform apply --auto-approve

backend_bucket_name=$(terraform output -raw backend_bucket_name)

cat << EOF > backend.config
bucket         = "${backend_bucket_name}"
region         = $(terraform output backend_bucket_region)
dynamodb_table = $(terraform output locking_dynamodb_table_name)
EOF

# Store the state of backend bucket & DynamoDB table inside the backend bucket as well
aws s3 cp terraform.tfstate s3://${backend_bucket_name}/backend-state/
aws s3 cp backend.config s3://${backend_bucket_name}/backend-state/

mv backend.config ../eks/

cd ../eks/
terraform init -backend-config="./backend.config"
terraform apply --auto-approve
