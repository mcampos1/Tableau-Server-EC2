#!/bin/bash
yum update -y
yum install wget nano firewalld -y
wget https://downloads.tableau.com/esdalt/2023.1.7/tableau-server-2023-1-7.x86_64.rpm
sudo yum install tableau-server-2023-1-7.x86_64.rpm -y
cd /opt/tableau/tableau_server/packages/scripts.20233.23.1017.0948
sudo ./initialize-tsm --accepteula --activation-service
exit
#will need to login to server again
#https://ip-10-117-13-49.ec2.internal:8850
