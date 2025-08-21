variable "aws_region" {
  default = "us-east-1"
}

variable "eks_cluster_name" {
  default = "ori-cluster"
}

variable "cluster_role_name" {
  default = "AmazonEKSClusterRole"
}

variable "node_group_name" {
  default = "ori-node-group"
}

variable "node_role_name" {
  default = "AmazonEKSNodeRole"
}

variable "subnet_ids" {
  type    = list(string)

  #  default = ["<subnet1-id>",
  #             "<subnet2-id>",
  #             "<subnet3-id>"]
}
