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
  
  tags = {
    Name = "prod_web_rt"
  }
}

resource "aws_route" "prod_web_route" { 
  route_table_id = aws_route_table.prod_web_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.prod_igw.id
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

# Create network acl // applies at the subnet level // 
resource "aws_network_acl" "prod_web_nacl" {
  vpc_id = aws_vpc.prod_vpc.id
  subnet_ids = [aws_subnet.prod_subnet_public_1.id, aws_subnet.prod_subnet_public_2.id]

  # Allow all
    ingress {
      protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  
  /* # Allow traffic port 22
    ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  } */

  tags = {
    Name = "prod_web_nacl"
  }

}

# Create a web server security group // applies at the instance level
resource "aws_security_group" "prod_web_sg" {
  name        = "web_server_sg"
  description = "Security group for the jump server"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
