# Create a VPC
resource "aws_vpc" "prod_vpc" {
	cidr_block = "172.16.0.0/16"
	enable_dns_hostnames = true
 
  tags = {
	Name = "prod_vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "prod_igw" {
	vpc_id = aws_vpc.prod_vpc.id
 
  tags = {
	Name = "prod_igw"
  }
}

# Create Elastic IP
resource "aws_eip" "prod_eip" {
	
	domain = "vpc" // changed from vpc = "true"
}

# Create NAT Gateway
resource "aws_nat_gateway" "prod_nat_gw" {
	allocation_id = aws_eip.prod_eip.id
	subnet_id = aws_subnet.prod_subnet_public_1.id
	depends_on = [aws_internet_gateway.prod_igw]

	tags = {
    	Name = "prod_nat_gw"
	}
}
