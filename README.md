# Fields - Cohort 9 - Team 2

This repository is currently under construction and incomplete. Please see below for the next steps.

![image](https://github.com/kalibri-actual/fields-c9t2-capstone/assets/155348375/d6d73526-acbb-4450-ac56-5da6c48ca5d7)

# Challenges
user_data scripts does not execute on prod_app_server_1 ec2 instance

# Workarounds
Removed (commented) the NACL everywhere. Solved the "connection reset by peer" problem.

# To Dos
Check if the load balancer actually works by installing php + apache on app_server_1 and app_server_2. This could be done via SSH from the jump server.
