variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "subnets" {
  type = list(object({
    name       = string
    az         = string
    cidr_block = string
  }))
  default = [
    {
      name       = "ori-subnet-1"
      az         = "eu-west-1a"
      cidr_block = "10.0.0.0/17"
    },
    {
      name       = "ori-subnet-2"
      az         = "eu-west-1b"
      cidr_block = "10.0.128.0/17"
    },
  ]
}

variable "instance_ami" {
  type    = string
  default = "ami-0a094c309b87cc107"
}

variable "key_pair" {
  type    = string
  default = "ori-key"
}