#!//bin/bash

# Author:Zhuo Cheng Wang (Vico)

# Project: Devops Course Assignment - Automation Project
# This script includes assignment part 2 & 3 requirements. 

########################################## Task 2 #########################################

# 1. Perform an update of the package details and the package list at the start of the script.
sudo apt update -y

# 2. Check the existence of the apache2 package and install it if the package is not installed.

pkg="apache2"

which $pkg > /dev/null 2>&1
if [ $? == 0 ]
then
echo "The $pkg has been installed. "
else
echo "The $pkg has not been installed, instilling now"
sudo apt install $pkg -y
sleep 30 # Give 30 seconds for the Apache2 package instllation. 
fi

# 3&4. Ensure that the apache2 service is running and enabled. 
servstat=$(sudo systemctl status apache2)

if [[ $servstat == *"active (running)"* ]]; then
  echo "Apache2 Service is running"
else
  echo "Apache2 Service is not running, now we start it"
  sudo systemctl start apache2
  sleep 2 # Give 2 sec for the Apache2 service to start
fi


# 5. Create a tar archive of apache2 access logs and error logs that are present in the /var/log/apache2/ directory and place the tar into the /tmp/ directory. 
# Get the timestamp 

myname="ZhuoChengWang"
timestamp=$(date '+%d%m%Y-%H%M%S')
FileName=${myname}-httpd-logs-${timestamp}.tar

tar -cvf $FileName /var/log/apache2/

# Get the size of the tar file and save it to a variable (for task 3)

sizeOfTar=$(wc --bytes $FileName | awk '{print $1}')

# Move the tar file into the /tmp/ directory

mv $FileName /tmp

# Move the tar file to the s3 bucket 

s3_bucket="upgrad-zhuocheng"
aws s3 cp /tmp/$FileName s3://${s3_bucket}/$FileName

########################################## Task 3 #########################################

# Ensure that your script checks for the presence of the inventory.html file in /var/www/html/; if not found, creates it.

# create a variable to check 
File=/var/www/html/inventory.html

if [ -f "$File" ]; then
	echo "$File exists."
	echo "<table width="500" cellspacing="12"><tr><td align="middle">httpd-logs</td><td align="middle">${timestamp}</td><td align="left">tar</td><td align="middle">${sizeOfTar}</td></tr></table>" >>$File
else
	echo "$File does not exist now we create a file."
	sudo touch $File
	sudo chmod 777 $File
	echo "<table width="500" cellspacing="12"><tr><th>Log Type</th><th>Date Created</th><th>Type</th><th>Size</th></tr></table>" >>$File
	echo "<table width="500" cellspacing="12"><tr><td align="middle">httpd-logs</td><td align="middle">${timestamp}</td><td align="left">tar</td><td align="middle">${sizeOfTar}</td></tr></table>" >>$File
fi

