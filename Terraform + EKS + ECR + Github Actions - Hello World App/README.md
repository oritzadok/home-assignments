### Prerequisites:
- An existing VPC and subnets that meet Amazon EKS requirements
  (this code is not responsible of creating these resources at this time.
   Also, best practice is to use private subnets for the EKS cluster)
- Terraform installed
- kubectl installed
- Helm installed

### Deploy:

1) Login to your AWS account programmatically, so Terraform will be able to create resources on your behalf.

2) Provide the subnets IDs in which you want the cluster to be created.
Specify the list of subnets in Terraform variable `subnet_ids` in `terraform/eks/variables.tf`.

3) Create the Terraform resources by running:
```
bash create_infra.sh
```

4) Create an AWS ECR repository.

5) Create Github repository secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ECR_REPOSITORY_URI`.
These secrets will be used in the Github Actions workflow.

6) Create Github repository variables: `AWS_REGION`, `EKS_CLUSTER`.
Make sure their values are same as provided to the corresponding Terraform variables in `terraform/eks/variables.tf`.
These variables will be used in the Github Actions workflow.

7) Now the app is ready to be deployed. Any code push to the `app` directory will trigger a pipeline the builds a Docker image and deploys the app on the EKS cluster.
The app will be publicly accessible through an AWS load balancer.

### Delete:

1) Delete the Github repository secrets and variables created for this app.

2) Detele the AWS ECR repository.

3) Uninstall the app:
```
helm uninstall hello-app -n hello-app
kubectl delete ns hello-app
```

4) Delete the Terraform resources by running:
```
bash delete_infra.sh
```
