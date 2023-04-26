##############################################
## Create Windows Server on AWS for App Control in the ap-southeast-1 region (ie, Singapore)
## Creates a WinServer 2019 EC2 t3.large instance
## Creates a VPC subnet of 192.168.10.0/24
## Creates a Public facing subnet of 192.168.10.0/24
## Creates a IGW
## Creates a Routing Table sending everything to IGW
## Creates a SG that only allows 3389/443/41002 inbound and all outbound
## Creates a EIP that associates it with the EC2 instance
##############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

##############################################
## Creates the underlying infrastructure
##############################################

# Creates App Control VPC
resource "aws_vpc" "appc_vpc" {
  cidr_block = var.appc_vpc

  tags = {
    Name        = "App Control VPC"
    Environment = "CB_Demo"
  }
}

# Creates Public Facing Subnet
resource "aws_subnet" "appc_subnet" {
  vpc_id     = aws_vpc.appc_vpc.id
  cidr_block = var.appc_subnet

  tags = {
    Name        = "App Control Subnet"
    Environment = "CB_Demo"
  }
}

# Creates Internet Gateway
resource "aws_internet_gateway" "appc_igw" {
  vpc_id = aws_vpc.appc_vpc.id

  tags = {
    Name        = "App Control VPC IGW"
    Environment = "CB_Demo"
  }
}

##############################################
## Creates the underlying routing
##############################################

# Creates Routing Table
resource "aws_route_table" "appc_rt" {
  vpc_id = aws_vpc.appc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.appc_igw.id
  }

  tags = {
    Name        = "App Control VPC RT"
    Environment = "CB_Demo"
  }
}

# Creates Route Table Association
resource "aws_main_route_table_association" "appc_rt_assocation" {
  vpc_id = aws_vpc.appc_vpc.id
  route_table_id = aws_route_table.appc_rt.id
}

#associate Route Table with subnet
resource "aws_route_table_association" "demo_rt_subnet" {
  subnet_id = aws_subnet.appc_subnet.id
  route_table_id = aws_route_table.appc_rt.id
}

##############################################
## Creates the security group for App Control
##############################################

#create Security Group
resource "aws_security_group" "appc_sg" {
  name   = "App Control SG"
  vpc_id = aws_vpc.appc_vpc.id

  #allow ingress
  ingress {
    description = "RDP to Win Server"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  ingress {
    description = "HTTPS access"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    description = "Agent Comms"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 41002
    to_port     = 41002
    protocol    = "tcp"
  }

  #allow egress  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App Control SG"
  }
}


##############################################
## Creates EC2 for App Control
##############################################

# Creates an EIP
resource "aws_eip" "appc_eip" {
  instance = aws_instance.appc_server.id

  tags = {
    Name = "App Control EIP"
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

# Creates Win Server EC2 instance
resource "aws_instance" "appc_server" {
  ami             = var.appc_ami
  instance_type   = var.appc_instance
  subnet_id       = aws_subnet.appc_subnet.id
  security_groups = [aws_security_group.appc_sg.id]
  key_name        = aws_key_pair.public_key.id

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = {
    Name        = "App Control"
    Environment = "CB-Demo"
  }
}