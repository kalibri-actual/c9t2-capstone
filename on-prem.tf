### Credit goes to Meena Rizwan ###

# on-prem-vpc #

# VPC
resource "aws_vpc" "corporate_data_center_vpc" {
  cidr_block            = "192.168.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  # Tags
  tags = {
    Name        = "Corporate Data Center VPC"
    Environment = "Production"
  }
}

# Public Subnet
resource "aws_subnet" "corporate_data_center_public_subnet" {
  vpc_id                  = aws_vpc.corporate_data_center_vpc.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  # Tags
  tags = {
    Name        = "Corporate Data Center Public Subnet"
    Environment = "Production"
    Purpose     = "Frontend"
  }
}

# Private Subnet
resource "aws_subnet" "corporate_data_center_private_subnet" {
  vpc_id                  = aws_vpc.corporate_data_center_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  # Tags
  tags = {
    Name        = "Corporate Data Center Private Subnet"
    Environment = "Production"
    Purpose     = "Backend"
  }
}



# Internet Gateway
resource "aws_internet_gateway" "corporate_data_center_internet_gateway" {
  vpc_id = aws_vpc.corporate_data_center_vpc.id
  # Tags
  tags = {
    Name        = "Corporate Data Center Internet Gateway"
    Environment = "Production"
  }
}

/* # VPN Gateway 
resource "aws_vpn_gateway" "corporate_data_center_vpn_gateway" {
  vpc_id = aws_vpc.corporate_data_center_vpc.id
  # Tags
  tags = {
    Name        = "Corporate Data Center VPN Gateway"
    Environment = "Production"
  }
}

# Customer Gateway
resource "aws_customer_gateway" "corporate_data_center_customer_gateway" {
  bgp_asn    = 65000
  type = "ipsec.1"
  ip_address = "203.0.113.1"
  # Tags
  tags = {
    Name        = "Corporate Data Center Customer Gateway"
    Environment = "Production"
  }
}

# VPN Connection
resource "aws_vpn_connection" "corporate_data_center_vpn_connection" {
  customer_gateway_id = aws_customer_gateway.corporate_data_center_customer_gateway.id
  vpn_gateway_id      = aws_vpn_gateway.corporate_data_center_vpn_gateway.id
  type          = "ipsec.1"
  # Tags
  tags = {
    Name        = "Corporate Data Center VPN Connection"
    Environment = "Production"
  }
} */

# NAT Gateway
resource "aws_nat_gateway" "corporate_data_center_nat_gateway" {
  allocation_id = aws_eip.corporate_data_center_eip.id
  subnet_id     = aws_subnet.corporate_data_center_public_subnet.id
  # Tags
  tags = {
    Name        = "Corporate Data Center NAT Gateway"
    Environment = "Production"
  }
}

resource "aws_eip" "corporate_data_center_eip" {
  domain = "vpc"
  # Tags
  tags = {
    Name        = "Corporate Data Center Elastic IP"
    Environment = "Production"
  }
}

/* # Security Group for Private Subnet
resource "aws_security_group" "corporate_data_center_private_sg" {
  name        = "corporate_data_center_private_sg"
  description = "Security group for Corporate Data Center Private Subnet"
  vpc_id      = aws_vpc.corporate_data_center_vpc.id
  # Inbound rule (Allow specific traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]  # Allow traffic from on-premises VPC
  }
  # Outbound rule (Allow traffic to specific destinations)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16", "172.20.0.0/22"]  # Allow traffic to prod and non-prod VPCs
  }
  # Tags
  tags = {
    Name        = "Corporate Data Center Security Group for Private Subnet"
    Environment = "Production"
  }
} */

/* resource "aws_route_table" "corporate_data_center_non_prod_route_table" {
  vpc_id = aws_vpc.corporate_data_center_vpc.id

  tags = {
    Name        = "Corporate Data Center VPN Connection Route Table to Non-Production VPC"
    Environment = "Production"
  }
} */

# Create route table
resource "aws_route_table" "corporate_data_center_prod_route_table" {
  vpc_id = aws_vpc.corporate_data_center_vpc.id

  tags = {
    Name        = "Corporate Data Center Route Table to Production VPC"
    Environment = "Production"
  }
}

# Create route
resource "aws_route" "corporate_data_center_prod_route" {
  route_table_id         = aws_route_table.corporate_data_center_prod_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.corporate_data_center_internet_gateway.id
}
# Create route table association - public
resource "aws_route_table_association" "corporate_data_center_prod_route_table_association" {
  subnet_id      = aws_subnet.corporate_data_center_public_subnet.id
  route_table_id = aws_route_table.corporate_data_center_prod_route_table.id
}
# Create route table association - private
resource "aws_route_table_association" "corporate_data_center_private_route_table_association" {
  subnet_id      = aws_subnet.corporate_data_center_private_subnet.id
  route_table_id = aws_route_table.corporate_data_center_prod_route_table.id
}

resource "aws_route" "on-prem-twg-route" {
  route_table_id         = aws_route_table.corporate_data_center_prod_route_table.id
  destination_cidr_block = "172.16.0.0/16"
  gateway_id             = aws_internet_gateway.corporate_data_center_internet_gateway.id
}

resource "aws_route" "on-prem-twg-route-2" {
  route_table_id         = aws_route_table.corporate_data_center_prod_route_table.id
  destination_cidr_block = "172.20.0.0/22"
  gateway_id             = aws_internet_gateway.corporate_data_center_internet_gateway.id
}  

# Create security group
resource "aws_security_group" "corporate_data_center_sg" {
  name        = "corporate_data_center_prod_sg"
  description = "Security group for Corporate Data Center Production VPC"
  vpc_id      = aws_vpc.corporate_data_center_vpc.id
  # Inbound rule (Allow specific traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }
  # Allow SSH
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }
  # Allow icmp - ping
    ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }

  # Allow outbound traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Tags
  tags = {
    Name        = "Corporate Data Center Security Group for Production VPC"
    Environment = "Production"
  }
}




/* # Network ACL for Private Subnet
resource "aws_network_acl" "corporate_data_center_private_nacl" {
  vpc_id = aws_vpc.corporate_data_center_vpc.id
  # Inbound rules
  ingress {
    protocol      = "tcp"
    rule_no       = 100
    action        = "allow"
    cidr_block    = "192.168.0.0/16"  # Allow traffic from the entire on-premises VPC
    from_port     = 80
    to_port       = 80
  }
  # Outbound rules
  egress {
    protocol      = "tcp"
    rule_no       = 200
    action        = "allow"
    cidr_block    = "172.16.0.0/16"   # Allow traffic to prod VPC
    from_port     = 443
    to_port       = 443
  }
  egress {
    protocol      = "tcp"
    rule_no       = 201
    action        = "allow"
    cidr_block    = "172.20.0.0/22"   # Allow traffic to non-prod VPC
    from_port     = 443
    to_port       = 443
  }
  # Tags
  tags = {
    Name        = "Corporate Data Center Network ACL for Private Subnet"
    Environment = "Production"
  }
} */

/* # Route Table for Corporate Data Center VPC
resource "aws_route_table" "corporate_data_center_route_table" {
  vpc_id = aws_vpc.corporate_data_center_vpc.id
  # Route for local traffic within the VPC
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = aws_vpc.corporate_data_center_vpc.id
  }
  # Tags
  tags = {
    Name        = "Corporate Data Center Route Table"
    Environment = "Production"
  }
} */

# Route Table for VPN Connection to Non-Production VPC


### EC2 Instance ###
resource "aws_instance" "corporate_data_center_instance" {
  ami                          = "ami-0f403e3180720dd7e"
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.corporate_data_center_public_subnet.id
  key_name                     = "capstone-key"
  associate_public_ip_address  = true
  vpc_security_group_ids       = [aws_security_group.corporate_data_center_sg.id]
  
  tags = {
    Name        = "Corporate Data Center Instance"
    Environment = "Production"
  }
}
