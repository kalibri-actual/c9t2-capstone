#!/bin/bash

# Update and install necessary packages
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd php-mbstring php-xml

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Add user to Apache group and set permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Create phpinfo.php
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php

# Restart Apache
sudo systemctl restart httpd

# Download and setup phpMyAdmin
cd /var/www/html
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
sudo tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C /var/www/html --strip-components 1
sudo rm phpMyAdmin-latest-all-languages.tar.gz
sudo mv config.sample.inc.php config.inc.php

# Secure phpMyAdmin (example - you should customize this based on your needs)
# For example, you might want to set a password and secure the configuration file

# Restart Apache again
sudo systemctl restart httpd
