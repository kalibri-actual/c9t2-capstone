### UNDER CONSTRUCTION ###
# This is a bare bones for the RDS tier. Follow step #5 on the link below:
# https://aws.plainenglish.io/three-tier-application-c911d67f2619

# DB tier

resource "aws_subnet" "prod_subnet_private_3" {
	vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "172.16.5.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "false"
 
  tags = {
	Name = "prod_subnet_private_3"
  }
}

resource "aws_subnet" "prod_subnet_private_4" {
	vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "172.16.6.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "false"
 
  tags = {
	Name = "prod_subnet_private_4"
  }
}

# Create DB server route table
resource "aws_route_table" "prod_db_rt" {
	vpc_id = aws_vpc.prod_vpc.id

	tags = {
		Name = "prod_db_rt"
	}
}

resource "aws_route" "prod_db_route" {
	route_table_id = aws_route_table.prod_db_rt.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.prod_nat_gw.id
}

# Create DB server route table association
resource "aws_route_table_association" "prod_db_rt_association_3" {
	subnet_id = aws_subnet.prod_subnet_private_3.id
	route_table_id = aws_route_table.prod_db_rt.id
}
resource "aws_route_table_association" "prod_db_rt_association_4" {
	subnet_id = aws_subnet.prod_subnet_private_4.id
	route_table_id = aws_route_table.prod_db_rt.id
}

# Create a database subnet group
resource "aws_db_subnet_group" "prod_rds_subnet_group" {
	name = "prod_rds_subnet_group"
	subnet_ids = [aws_subnet.prod_subnet_private_3.id, aws_subnet.prod_subnet_private_4.id]
}

# Create a security group for RDS
resource "aws_security_group" "prod_rds_sg" {
	name = "prod_rds_sg"
	description = "Allow inbound from APP"
	vpc_id = aws_vpc.prod_vpc.id

	ingress {
    	description = "APP from VPC"
    	from_port = 3306
    	to_port = 3306
    	protocol = "tcp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	egress {
    	from_port = 0
    	to_port = 0
    	protocol = "-1"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	ingress {
    	description = "SSH from APP"
    	from_port = 22
    	to_port = 22
    	protocol = "tcp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	egress {
    	from_port = 0
    	to_port = 0
    	protocol = "-1"
    	cidr_blocks = ["0.0.0.0/0"]
	}

	# Allow HTTP traffic
	ingress {
    	description = "HTTP from APP"
    	from_port = 80
    	to_port = 80
    	protocol = "tcp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	# Allow HTTPS traffic
	ingress {
    	description = "HTTPS from APP"
    	from_port = 443
    	to_port = 443
    	protocol = "tcp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	# Allow ping
	ingress {
    	description = "Ping from APP"
    	from_port = 8
    	to_port = 0
    	protocol = "icmp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	tags = {
    	Name = "prod_rds_sg"
	}
}

/* # Create a network acl
resource "aws_network_acl" "prod_db_acl" {
	vpc_id = aws_vpc.prod_vpc.id
	#subnet_ids = [aws_subnet.prod_subnet_private_3.id, aws_subnet.prod_subnet_private_4.id] 

	egress {
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		protocol = "-1"
		to_port = 0
	}

	ingress {
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		protocol = "-1"
		to_port = 0
	}

	tags = {
		Name = "prod_db_acl"
	}
} */

# Create rds security group
resource "aws_security_group" "prod_rds_sg" {
	name = "prod_rds_sg"
	description = "Allow inbound from APP"
	vpc_id = aws_vpc.prod_vpc.id

	ingress {
    	description = "APP from VPC"
    	from_port = 3306
    	to_port = 3306
    	protocol = "tcp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	/* egress {
    	from_port = 0
    	to_port = 0
    	protocol = "-1"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	}

	ingress {
    	description = "SSH from APP"
    	from_port = 22
    	to_port = 22
    	protocol = "tcp"
    	cidr_blocks = ["172.16.3.0/24", "172.16.4.0/24"]
	} */
}

# Create rds instance
resource "aws_db_instance" "prod_rds" {
	identifier = "prod_rds"
	allocated_storage = 20
	storage_type = "gp2"
	engine = "mysql"
	engine_version = "5.7"
	instance_class = "db.t2.micro"
	username = "admin"
	password = "admin1234"
	vpc_security_group_ids = [aws_security_group.prod_rds_sg.id]
	db_subnet_group_name = aws_db_subnet_group.prod_rds_subnet_group.name
	#network_acl_id = aws_network_acl.prod_db_acl.id
	skip_final_snapshot = true
	multi_az = true
	backup_retention_period = 7
	deletion_protection = false
	storage_encrypted = true
	apply_immediately = true

	tags = {
		Name = "prod_rds"
	}
}







