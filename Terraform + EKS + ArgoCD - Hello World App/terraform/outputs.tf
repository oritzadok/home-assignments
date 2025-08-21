output "aws_region" {
  value = var.aws_region
}

output "eks_cluster_name" {
  value = aws_eks_cluster.cluster.name
}