terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}




resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ori-vpc"
  }
}


resource "aws_subnet" "subnet" {
  count             = length(var.subnets)

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.subnets[count.index].az
  cidr_block              = var.subnets[count.index].cidr_block
  # For "Auto-assign public IPv4 address"
  #map_public_ip_on_launch = true

  tags = {
    Name = var.subnets[count.index].name
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "ori-igw"
  }
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "ori-rt"
  }
}


resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet[0].id
  route_table_id = aws_route_table.rt.id
}


# Was not able to create an Elastic IP.
# The error: "Elastic IP address could not be allocated. The maximum number of addresses has been reached."
#resource "aws_eip" "eip" {
#  instance = aws_instance.instance.id
#}


resource "aws_nat_gateway" "ngw" {
  #allocation_id = aws_eip.eip.id
  # Used an existing one since was not able to create an Elastic IP.

  allocation_id = "eipalloc-01b14224f4dcde49a"
  subnet_id     = aws_subnet.subnet[0].id

  tags = {
    Name = "ori-ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "ori-rt2"
  }
}


resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet[1].id
  route_table_id = aws_route_table.rt2.id
}


resource "aws_efs_file_system" "fs" {
  creation_token = "ori-efs"

  tags = {
    Name = "ori-efs"
  }
}


resource "aws_security_group" "mount_target_sg" {
  name        = "allow access to efs"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "allow_access_to_efs"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_nfs_ipv4" {
  security_group_id = aws_security_group.mount_target_sg.id
  cidr_ipv4         = aws_subnet.subnet[0].cidr_block
  from_port         = 2049
  ip_protocol       = "tcp"
  to_port           = 2049
}


resource "aws_vpc_security_group_ingress_rule" "allow_nfs_for_lambda" {
  security_group_id = aws_security_group.mount_target_sg.id
  referenced_security_group_id = aws_security_group.lambda_sg.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
}


resource "aws_efs_mount_target" "mt" {
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = aws_subnet.subnet[0].id
  security_groups = [aws_security_group.mount_target_sg.id]
}


resource "aws_efs_mount_target" "mt2" {
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = aws_subnet.subnet[1].id
  security_groups = [aws_security_group.mount_target_sg.id]
}


resource "aws_security_group" "instance_sg" {
  name        = "ori instance security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "ori_instance"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "outbound_all" {
  security_group_id = aws_security_group.instance_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}


resource "aws_instance" "instance" {
  ami           = var.instance_ami
  instance_type = "t2.micro"
  key_name      = var.key_pair
  subnet_id     = aws_subnet.subnet[0].id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.instance_sg.id]


  tags = {
    Name = "ori-instance"
  }

  user_data = templatefile("./user_data.tfpl", {file_system_id = aws_efs_file_system.fs.id})
}


resource "aws_efs_access_point" "access_point_for_lambda" {
  file_system_id = aws_efs_file_system.fs.id

  posix_user {
    gid = 0
    uid = 0
  }
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}


resource "aws_iam_role_policy_attachment" "AmazonElasticFileSystemClientReadWriteAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
  role       = aws_iam_role.iam_for_lambda.name
}


resource "aws_iam_policy" "lambda_access_vpc" {
  name = "ori-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeVpcs"
                   ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = aws_iam_policy.lambda_access_vpc.arn
  role       = aws_iam_role.iam_for_lambda.name
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda_role_ori"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_security_group" "lambda_sg" {
  name        = "ori lambda security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "ori_lambda"
  }
}


resource "aws_vpc_security_group_egress_rule" "outbound_nfs" {
  security_group_id = aws_security_group.lambda_sg.id

  referenced_security_group_id = aws_security_group.mount_target_sg.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
}


resource "aws_vpc_security_group_egress_rule" "outbound_all_lambda" {
  security_group_id = aws_security_group.lambda_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}


resource "aws_lambda_function" "function" {
  filename      = "lambda_function_payload.zip"
  function_name = "ori-lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  file_system_config {
    arn = aws_efs_access_point.access_point_for_lambda.arn

    # Must start with '/mnt/'.
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.subnet[1].id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_efs_mount_target.mt2]
}