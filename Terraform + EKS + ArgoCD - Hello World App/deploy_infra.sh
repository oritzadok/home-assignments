cd terraform

# Create EKS cluster, with Argo CD installed on top
terraform init
terraform apply -auto-approve


# Create Argo CD application in the cluster

aws eks update-kubeconfig --region $(terraform output -raw aws_region) --name $(terraform output -raw eks_cluster_name)

kubectl apply -f ../argocd/application.yaml