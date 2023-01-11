Tableau Server Deployment on AWS EC2
Version 2022 3.2

Tableau is a leading data visualization tool used for data analysis and business intelligence.
Analytics platform makes it easier for people to explore and manage data, and faster to discover and share insights that can change businesses and the world.
Tableau is the most powerful, secure, and flexible end-to-end analytics platform.

EC2 Server Provisioning
Before starting Tableau Server Installation review minimum requirements
https://help.tableau.com/current/server-linux/en-us/server_hardware_min.htm

To deploy to an AWS EC2 review:
https://help.tableau.com/current/server/en-us/ts_aws_single_server.htm

Acceptable EC2 types:

C5.4xlarge (suitable for development environments only)

m5.4xlarge (suitable for development or testing environments only)

r5.4xlarge (suitable for development, testing, or production environments)

Operating System:
Amazon Linux 2
EC2 instance should be in the same VPC and subnet where key cloak is hosted

Storage Requirements:
30-50 GiB volume for the operating system
100 GiB or larger volume for Tableau Server
EBS recommended (SSD (gp2) or Provisioned IOPS)

Security Groups: 
Ports 22,80,443,8850 

Attach a new key pair or use an existing one
Once Instance is running, SSH into instance with keypair

Userdata bashscript:
#Install packages on EC2 Instance
#!/bin/bash
yum update -y
yum install wget nano NetworkManager-tui wget bind-utils net-tools -y

Tableau Server Installation
https://help.tableau.com/current/server-linux/en-us/setup.htm

find the latest Tableau Server rpm version:
https://www.tableau.com/support/releases/server

use wget to download tableau server package to server
right click on latest version package and copy link address
https://www.tableau.com/support/releases/server

wget https://downloads.tableau.com/esdalt/2022.3.0/tableau-server-2022-3-0.x86_64.rpm
sudo yum install tableau-server.rpm -y
cd /opt/tableau/tableau_server/packages/scripts.<version_code>/
sudo ./initialize-tsm --accepteula --activation-service

The only required parameter for the initialize-tsm script is --accepteula
add xadmin to tsmadmin group

sudo usermod -G tsmadmin -a xadmin

Exit out of current shell and reopen to have updated shell

To continue installing Tableau using the TSM Web Interface (GUI):
https://ip-ipaddress.ec2.internal:8850
http://ip-address:8850

Activate Tableau:
https://help.tableau.com/current/server-linux/en-us/activate.htm
No license use 2 week free trial:

tsm licenses activate -t

Login to customer portal to obtain tableau server license key:
https://www.tableau.com/tableau-login-hub

tsm licenses activate -k 1234-5768-9999-1236 #activate a license

Tableau Server Registration
create registration json file and edit values, json file template:
https://help.tableau.com/current/server-linux/en-us/activate.htm

nano registration.json
tsm register --file registration.json

Identity Store Configuration
Create local identity store settings file from template:
https://help.tableau.com/current/server-linux/en-us/entity_identity_store.htm\
add local settings template from
https://help.tableau.com/current/server-linux/en-us/config_general.htm
import file, initialize server and create tableau administrator account

nano local.json
tsm settings import -f local.json
tsm pending-changes apply
tsm initialize --start-server --request-timeout 1800
tabcmd initialuser --server http://localhost --username 'desired usernmame'

Configure SSL on Tableau Server:
https://help.tableau.com/current/server/en-us/ssl_config.htm

obtain 3 files:
name-ca
server.key
server.crt

Sign in to the TSM Web interface (GUI) on the browser
https://:8850
Configuration Tab > Security > External SSL
Select the 3 files
Save pending changes > apply pending changes

Setting Up Initial user in Keycloak and Tableau Server
After creating administrator account, login into Tableau Server using the private IP adddress and the administrator account credentials created.
Create users on Tableau Server, username should be in email format (ex. Tableauadmin@local.net)
Login into Keycloak Realm for Tableau, add users and include email value for the users (ex. tableauadmin@local.net), username doesn't need to be an email on keycloak
Tableau by default maps users' email claim from the identity provider (Keycloak) to users' username in Tableau Server. (keycloak user's email == Tableau user's username)
Integrate Tableau Server with KeyCloak
Once a user has been created in keycloak and tableau server, create identity.json and copy openid template: https://help.tableau.com/current/server-linux/en-us/entity_openid.htm
Edit the values, then run:

tsm settings import -f identity.json
tsm pending-changes apply

Troubleshooting OpenID Connect:
https://help.tableau.com/current/server/en-us/openid_auth_troubleshooting.htm

To deactivate license review:
https://help.tableau.com/current/server/en-us/license_deactivate.htm

tsm licenses list
tsm licenses deactivate --license-key 
tsm pending-changes apply
tsm restart

Installing Database Drivers
https://www.tableau.com/support/drivers
mkdir -p /opt/tableau/tableau_driver/jdbc
wget driver-url

Optional
To change the default claim tableau uses to map users with keycloak:
https://help.tableau.com/current/server-linux/en-us/cli_authentication_tsm.htm#TSMOIDC
tsm authentication openid map-claims -un username

