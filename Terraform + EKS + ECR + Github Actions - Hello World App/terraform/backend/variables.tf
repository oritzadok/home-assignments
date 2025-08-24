variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "oriza-tfstate"
}

variable "dynamodb_table_name" {
  type    = string
  default = "oriza-tfstate-lockid"
}