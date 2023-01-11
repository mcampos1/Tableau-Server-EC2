#!/bin/bash
yum update -y
yum install wget nano NetworkManager-tui net-tools bind-utils -y
wget https://downloads.tableau.com/esdalt/2022.3.2/tableau-server-2022-3-2.x86_64.rpm
sudo yum install tableau-server-2022-1-2.x86_64.rpm -y
cd /opt/tableau/tableau_server/packages/scripts.20223.22.1213.1425/
sudo ./initialize-tsm --accepteula --activation-service
exit
#will need to login to server again
#https://ip-10-117-13-49.ec2.internal:8850
