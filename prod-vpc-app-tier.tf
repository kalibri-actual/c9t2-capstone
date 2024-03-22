### App tier ###
# By far the most challenging one in Terraform especially setting up the application load balancer

# Create private subnets
resource "aws_subnet" "prod_subnet_private_1" {
	vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "172.16.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "false"
 
  tags = {
	Name = "prod_subnet_private_1"
  }
}

resource "aws_subnet" "prod_subnet_private_2" {
	vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "172.16.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "false"
 
  tags = {
	Name = "prod_subnet_private_2"
  }
}

# Create app server route table
resource "aws_route_table" "prod_app_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod-app-rt"
  }
}

# Create app server route
resource "aws_route" "prod_app_route-to-nat-gw" {
  route_table_id            = aws_route_table.prod_app_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  #gateway_id = aws_internet_gateway.prod_igw.id
  nat_gateway_id = aws_nat_gateway.prod_nat_gw.id
}

resource "aws_route" "prod-app-route-to-on-prem" {
  route_table_id            = aws_route_table.prod_app_rt.id
  destination_cidr_block    = "192.160.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

# Associate app server route table with app server subnets
resource "aws_route_table_association" "prod_app_rt_association_1" {
  subnet_id      = aws_subnet.prod_subnet_private_1.id
  route_table_id = aws_route_table.prod_app_rt.id
}
resource "aws_route_table_association" "prod_app_rt_association_2" {
  subnet_id      = aws_subnet.prod_subnet_private_2.id
  route_table_id = aws_route_table.prod_app_rt.id
}

/* # Create network acl
resource "aws_network_acl" "prod_app_nacl" {
  vpc_id     = aws_vpc.prod_vpc.id
  subnet_ids = [aws_subnet.prod_subnet_private_1.id, aws_subnet.prod_subnet_private_2.id]

  # Allow ephemeral ports egress
    egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "prod-app-nacl"
  }
} */



# Create security group - app
resource "aws_security_group" "prod_app_sg" {
  name = "app_server_sg"
  description = "Security group for app-server"
  vpc_id      = aws_vpc.prod_vpc.id

  # Allow SSH from prod_jump_server
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP traffic
    ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // changed from 0.0.0.0/0
  }

  # Allow HTTPS traffic
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

    tags = {
    Name = "prod_app_sg"
  }
}

### EC2 Instances ###
resource "aws_instance" "prod_app_server_1" {
	ami = "ami-0f403e3180720dd7e" #"ami-0aedf6b1cb669b4c7" // Cent OS
	instance_type = "t2.micro"
	key_name = "capstone-key"
  subnet_id = aws_subnet.prod_subnet_private_1.id
  security_groups = [aws_security_group.prod_app_sg.id]
	user_data = "${file("prod-app-server.sh")}"
  
	tags = {
    	Name = "prod_app_server_1"
	}

}

resource "aws_instance" "prod_app_server_2" {
	ami = "ami-0f403e3180720dd7e" //amazon linux #"ami-0aedf6b1cb669b4c7" // Cent OS
	instance_type = "t2.micro"
	key_name = "capstone-key"
  subnet_id = aws_subnet.prod_subnet_private_2.id
  security_groups = [aws_security_group.prod_app_sg.id]
	user_data = "${file("prod-app-server.sh")}"
  
	tags = {
    	Name = "prod_app_server_2"
	}

}

# Create EBS volume for app server
resource "aws_ebs_volume" "prod_app_server_1_ebs" {
  availability_zone = "us-east-1a"
  size = 5
  encrypted = true
  type = "gp2"

  tags = {
    Name = "prod_app_server_1_ebs"
  }
}

# Attach EBS volume to app server
resource "aws_volume_attachment" "prod_app_server_1_ebs_att" {
  device_name = "/dev/xvdb"
  volume_id = aws_ebs_volume.prod_app_server_1_ebs.id
  instance_id = aws_instance.prod_app_server_1.id
}

## challenging to setup --- maybe beneficial to do it manually -- Application LB 

