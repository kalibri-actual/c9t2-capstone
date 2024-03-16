terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Define AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "non-prod_vpc" { 
  cidr_block = "172.20.0.0/22"
  
  tags = {
    Name = "non-prod_vpc"
  }
}

# Create NAT gateway
#resource "aws_nat_gateway" "nat_gateway" {
#  allocation_id = aws_eip.nat_eip.id
#  subnet_id     = aws_subnet.private_subnet.id
#}
# Create Elastic IP for NAT gateway
#resource "aws_eip" "nat_eip" {
#  domain = "vpc"
#}

# Create private subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.non-prod_vpc.id
  cidr_block = "172.20.0.0/23"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
}

# Create route table for private subnet
#resource "aws_route_table" "private_rt" {
#  vpc_id = aws_vpc.my_vpc.id
#}

# Create route for private subnet
#resource "aws_route" "private_route" {
#  route_table_id         = aws_route_table.private_rt.id
#  destination_cidr_block = "0.0.0.0/0"
#  nat_gateway_id = aws_nat_gateway.nat_gateway.id
#}

# Create security group (adjust rules as needed) // Create rules to be more secure
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.non-prod_vpc.id

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from anywhere (for public subnet)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to the internet // do we need this?
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances (adjust AMIs and configurations as needed) 
resource "aws_instance" "aws_linux_instance" {
  ami           = "ami-0440d3b780d96b29d" // AWS Linux
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "debian_instance" {
  ami           = "ami-058bd2d568351da34" // Debian 12
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "ubuntu_instance" {
  ami           = "ami-07d9b9ddc6cd8dd30" // Ubuntu 22.04
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "windows_instance" {
  ami           = "ami-0f9c44e98edf38a2b" // Windows
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "redhat_instance" {
  ami           = "ami-0fe630eb857a6ec83" // Red Hat
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}
