# Create transit gateway
resource "aws_ec2_transit_gateway" "transit_gateway" {
    description = "Transit gateway"
    auto_accept_shared_attachments = "enable"
    transit_gateway_cidr_blocks = ["0.0.0.0/24"]
}

# Create VPC attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "prod-vpc_attachment" {
    subnet_ids = [aws_subnet.prod_subnet_public_1.id, aws_subnet.prod_subnet_public_2.id]
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
    vpc_id = aws_vpc.prod_vpc.id
}
resource "aws_ec2_transit_gateway_vpc_attachment" "non-prod-vpc_attachment" {
    subnet_ids = [aws_subnet.non_prod-private_subnet.id]
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
    vpc_id = aws_vpc.non-prod_vpc.id
}
resource "aws_ec2_transit_gateway_vpc_attachment" "corporate_data_center_vpc" {
    subnet_ids = [aws_subnet.corporate_data_center_public_subnet.id]
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
    vpc_id = aws_vpc.corporate_data_center_vpc.id
}





