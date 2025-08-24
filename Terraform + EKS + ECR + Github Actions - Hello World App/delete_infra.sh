#!/bin/bash

backend_bucket_name="oriza-tfstate"

cd terraform/eks/
aws s3 cp s3://${backend_bucket_name}/backend-state/backend.config ./
terraform init -backend-config="./backend.config"
terraform destroy --auto-approve

cd ../backend/
aws s3 cp s3://${backend_bucket_name}/backend-state/terraform.tfstate ./
terraform init
terraform destroy --auto-approve
