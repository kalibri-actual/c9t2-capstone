# non-prod-vpc #

# Create VPC
resource "aws_vpc" "non-prod_vpc" { 
  cidr_block = "172.20.0.0/22"
  
  tags = {
    Name = "non-prod_vpc"
  }
}

# Create private subnet within the VPC
resource "aws_subnet" "non_prod-private_subnet" {
  vpc_id     = aws_vpc.non-prod_vpc.id
  cidr_block = "172.20.0.0/23"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "non_prod-private_subnet"
  }
}


# Create route table
resource "aws_route_table" "non_prod-private_rt" {
  vpc_id = aws_vpc.non-prod_vpc.id

  tags = {
    Name = "non_prod-private_rt"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "non_prod-igw" {
  vpc_id = aws_vpc.non-prod_vpc.id

  tags = {
    Name = "non_prod-igw"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "non_prod-nat_gw" {
  allocation_id = aws_eip.non_prod-nat_eip.id
  subnet_id     = aws_subnet.non_prod-private_subnet.id

  tags = {
    Name = "non_prod-nat_gw"
  }
}

# Create Elastic IP
resource "aws_eip" "non_prod-nat_eip" {
  domain      = "vpc"
}

# Create route
resource "aws_route" "non_prod-private_route" {
  route_table_id         = aws_route_table.non_prod-private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.non_prod-nat_gw.id
}

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

  # Allow HTTPS access from anywhere (for public subnet)
  ingress {
    from_port   = 443
    to_port     = 443
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
  subnet_id     = aws_subnet.non_prod-private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "debian_instance" {
  ami           = "ami-058bd2d568351da34" // Debian 12
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.non_prod-private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "ubuntu_instance" {
  ami           = "ami-07d9b9ddc6cd8dd30" // Ubuntu 22.04
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.non_prod-private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "windows_instance" {
  ami           = "ami-0f9c44e98edf38a2b" // Windows
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.non_prod-private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_instance" "redhat_instance" {
  ami           = "ami-0fe630eb857a6ec83" // Red Hat
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.non_prod-private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

