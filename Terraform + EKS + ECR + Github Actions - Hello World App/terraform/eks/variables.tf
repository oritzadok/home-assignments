variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "eks_cluster_name" {
  type    = string
  default = "ori-cluster"
}

variable "node_group_name" {
  type    = string
  default = "ori-node-group"
}

variable "subnet_ids" {
  type    = list(string)

  #  default = ["<subnet1-id>",
  #             "<subnet2-id>",
  #             "<subnet3-id>"]
}
