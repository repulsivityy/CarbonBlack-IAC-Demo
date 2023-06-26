##############################################
## Create CentOS 7 Server on AWS for EDR in the ap-southeast-1 region (ie, Singapore)
## Creates a CentOS EC2 t3.large instance
## Creates a VPC subnet of 192.168.20.0/24
## Creates a Public facing subnet of 192.168.20.0/24
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

# Creates EDR VPC
resource "aws_vpc" "edr_vpc" {
  cidr_block = var.edr_vpc

  tags = {
    Name        = "EDR VPC"
    Environment = "CB_Demo"
  }
}

# Creates Public Facing Subnet
resource "aws_subnet" "edr_subnet" {
  vpc_id     = aws_vpc.edr_vpc.id
  cidr_block = var.edr_subnet

  tags = {
    Name        = "EDR Subnet"
    Environment = "CB_Demo"
  }
}

# Creates Internet Gateway
resource "aws_internet_gateway" "edr_igw" {
  vpc_id = aws_vpc.edr_vpc.id

  tags = {
    Name        = "EDR VPC IGW"
    Environment = "CB_Demo"
  }
}

##############################################
## Creates the underlying routing
##############################################

# Creates Routing Table
resource "aws_route_table" "edr_rt" {
  vpc_id = aws_vpc.edr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.edr_igw.id
  }

  tags = {
    Name        = "EDR VPC RT"
    Environment = "CB_Demo"
  }
}

# Creates Route Table Association
resource "aws_main_route_table_association" "edr_rt_assocation" {
  vpc_id = aws_vpc.edr_vpc.id
  route_table_id = aws_route_table.edr_rt.id
}

#associate Route Table with subnet
resource "aws_route_table_association" "demo_rt_subnet" {
  subnet_id = aws_subnet.edr_subnet.id
  route_table_id = aws_route_table.edr_rt.id
}

##############################################
## Creates the security group for EDR
##############################################

#create Security Group
resource "aws_security_group" "edr_sg" {
  name   = "EDR SG"
  vpc_id = aws_vpc.edr_vpc.id

  #allow ingress
  ingress {
    description = "SSH Access"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    description = "HTTPS access"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
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
    Name = "EDR SG"
  }
}


##############################################
## Creates EC2 for EDR
##############################################

# Creates an EIP
resource "aws_eip" "edr_eip" {
  instance = aws_instance.edr_server.id

  tags = {
    Name = "EDR EIP"
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

# Creates CentOS Server EC2 instance
resource "aws_instance" "edr_server" {
  ami             = var.edr_ami
  instance_type   = var.edr_instance
  subnet_id       = aws_subnet.edr_subnet.id
  security_groups = [aws_security_group.edr_sg.id]
  key_name        = aws_key_pair.public_key.id

  user_data = <<EOF
  #!/bin/bash
  echo "Changing Hostname" 
  sudo hostnamectl set-hostname cb-edrserver
  
  echo "updating cent os"
  sudo yum update
  
  EOF

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = {
    Name        = "EDR-Server"
    Environment = "CB-Demo"
  }

/*
# provisioner
provisioner "file" {
    source = "/Users/dominicc1/Desktop/edr-license.zip"
    destination = "/home/centos/edr-license.zip"

        connection {
            type = "ssh"
            user = "centos"
            private_key = file("/Users/dominicc1/Desktop/Dominic/Dom_AWS_Keypair.pem") 
            host = self.associate_public_ip_address
        }
  }
*/
}