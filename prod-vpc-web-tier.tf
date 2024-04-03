#### Web tier ####

# Create 2 public subnets
resource "aws_subnet" "prod_subnet_public_1" {
	vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "172.16.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
 
  tags = {
	Name = "prod_subnet_public_1"
  }
}

resource "aws_subnet" "prod_subnet_public_2" {
	vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "172.16.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
 
  tags = {
	Name = "prod_subnet_public_2"
  }
}

# Create a route table
resource "aws_route_table" "prod_web_rt" {
  vpc_id = aws_vpc.prod_vpc.id
  
  # Route to igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  # Route to transit gateway to on-prem
  route {
    cidr_block = "192.168.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }
  
  tags = {
    Name = "prod_web_rt"
  }
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "prod_web_rt_assoc_1" {
  subnet_id      = aws_subnet.prod_subnet_public_1.id
  route_table_id = aws_route_table.prod_web_rt.id
}

resource "aws_route_table_association" "prod_web_rt_assoc_2" {
  subnet_id      = aws_subnet.prod_subnet_public_2.id
  route_table_id = aws_route_table.prod_web_rt.id
}

# Create network acl // applies at the subnet level // not too complicated but it will mess up your network // allow all traffic

# Create a web server security group // applies at the instance level
resource "aws_security_group" "prod_web_sg" {
  name        = "web_server_sg"
  description = "Security group for the jump server"
  vpc_id      = aws_vpc.prod_vpc.id

# Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow all - outgoing
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Outgoing TCP port 443
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
# Outgoing port 8834
  egress {
    from_port   = 8834
    to_port     = 8834
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web_server_sg"
  }
}

### EC2 resources ###

# Create jump_server EC2 instance
resource "aws_instance" "jump_server" {
  ami                         = "ami-0f403e3180720dd7e"
  instance_type               = "t2.micro"
  key_name                    = "capstone-key"
  subnet_id                   = aws_subnet.prod_subnet_public_1.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.prod_web_sg.id]

    tags = {
    Name = "jump_server"
  }
}
