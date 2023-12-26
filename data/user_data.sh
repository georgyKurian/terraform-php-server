#! /bin/bash
sudo su

# Update softwares
apt-get update -y

# Install Apache
apt-get install -y apache2

# Start Apache
systemctl start apache2

# Enable Apache to start on boot
systemctl enable apache2

# Write html file
echo “Hello World from $(hostname -f)” > /var/www/html/index.html