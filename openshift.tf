# Author : Lionel Lee
# Version : 0.1

# Configure AWS provider
provider "aws" {
  region     = "ap-south-1" # Change to your desired region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Define variables for AWS access credentials
variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}

# Create VPC
resource "aws_vpc" "openshift-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "openshift-vpc"
  }
}

# Create public subnet
resource "aws_subnet" "openshift-sub" {
  vpc_id            = aws_vpc.openshift-vpc.id
  cidr_block        = "10.0.0.0/24" # Adjust CIDR block as needed
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "openshift-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "openshift_igw" {
  vpc_id = aws_vpc.openshift-vpc.id
  tags = {
    Name = "openshift-IGW"
  }
}

# Create public route table
resource "aws_route_table" "openshift_route_table" {
  vpc_id = aws_vpc.openshift-vpc.id
  tags = {
    Name = "openshift-pub-RT"
  }
}

# Add default route to public route table
resource "aws_route" "my_route" {
  route_table_id         = aws_route_table.openshift_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.openshift_igw.id
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.openshift-sub.id
  route_table_id = aws_route_table.openshift_route_table.id
}

# Create security group
resource "aws_security_group" "openshift-sg" {
  name        = "openshift-sg"
  description = "Allow traffic from all"
  vpc_id      = aws_vpc.openshift-vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openshift-security-group"
  }
}

# Generate RSA key pair
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key_pair" {
  key_name   = "aws_key_pair"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = "key_pair.pem"
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami           = "ami-0b6ef6629d4230b38"  # Replace with your desired AMI ID
  instance_type = "m6a.xlarge"
  subnet_id     = aws_subnet.openshift-sub.id
  vpc_security_group_ids = [aws_security_group.openshift-sg.id]
  key_name      = aws_key_pair.aws_key_pair.key_name
  source_dest_check = false

  tags = {
    Name   = "openshift-master-instance"
    backup = "Yes"
    group  = "web"
  }
}

# Create Route53 hosted zone
resource "aws_route53_zone" "example_zone" {
  name    = "sandbox2.acme2.com"
  comment = "Example hosted zone"
  tags = {
    Environment = "Production"
  }
}
