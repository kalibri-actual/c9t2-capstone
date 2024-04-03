# Deploy a secure hybrid cloud environment using Terraform
For learning purposes only.

Objective:

:white_check_mark:    Create a three-tier highly available application environment in a Production VPC. <br>
:white_check_mark:    A Non-production environment in a separate VPC. <br>
:white_check_mark:    An On-prem environment (simulated with an AWS VPC) <br>
:white_check_mark:    Connect VPCs using transit gateway <br>
:black_square_button: Simulate Site-to-Site VPN Customer Gateways Using strongSwan <br>

![image](https://github.com/kalibri-actual/fields-c9t2-capstone/assets/155348375/d6d73526-acbb-4450-ac56-5da6c48ca5d7)

# To Do's
- Create a key pair named capstone-key to SSH to the jump server.
- user_data scripts are not working upon deployment. Probable solution: launch template(?). Alternative: install php and apache manually.
- ~~Create transit gateway.~~
- ~~Create transit gateway attachments.~~
- ~~Create customer gateway on the Corporate Data Center.~~
- Site-to-site VPN between the transit gateway and customer gateway.
- Update the image - add jump server on non-prod
- Generate key pair using Terraform

# Challenges
- user_data scripts do not execute on prod_app_server_1 ec2 instance
- ~~could not get to communicate VPC to one another. Another solution on this one is by peering connection.~~
