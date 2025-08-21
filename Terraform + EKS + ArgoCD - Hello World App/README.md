### Prerequisites:
- An existing VPC and subnets that meet Amazon EKS requirements
  (this code is not responsible of creating these resources at this time)
- Terraform installed
- Login to your AWS account (AWS CLI)
- kubectl installed

### Deploy:

1) Provide the subnets IDs on which you want the cluster to be created.
This is specified using terraform variable `subnet_ids`.

2) Run:
```
bash deploy_infra.sh
```

The address of the created ALB will be used to access the web app.

### Delete:
- Navigate to terraform/ directory and execute `terraform destroy -auto-approve`
- Delete the AWS ELBs created for the cluster services
  (better to delete the ArgoCD application for proper resource cleanup)
