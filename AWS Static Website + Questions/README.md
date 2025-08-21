### Prerequisites:
- Install Terraform
- Login to your AWS account

### Run:
```
terraform init
terraform apply --auto-approve
```

The AWS region and S3 bucket name are parameters with default values.
If you wish to override them, add this to the apply command: `-var="aws_region=<region>" -var="bucket_name=<bucket name>"`

The file upload to the bucket is done with Terraform (there's only one file - index.html).
Files can be manually uploaded as well.