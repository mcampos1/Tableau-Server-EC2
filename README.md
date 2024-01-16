# Tableau Server on AWS EC2

Tableau is a leading data visualization tool used for data analysis and business intelligence.
Analytics platform makes it easier for people to explore and manage data, and faster to discover and share insights that can change businesses and the world.
Tableau is the most powerful, secure, and flexible end-to-end analytics platform.

EC2 Server Provisioning

[TableauServer-MinimumRequirements](https://help.tableau.com/current/server-linux/en-us/server_hardware_min.htm)


[EC2-Configuration](https://help.tableau.com/current/server-linux/en-us/ts_aws_virtual_machine_selection.htm)

**Acceptable EC2 types:**

* C5.4xlarge (suitable for development environments only)
* m5.4xlarge (suitable for development or testing environments only)
* r5.4xlarge (suitable for development, testing, or production environments)

**Operating System:**

* RHEL7.9
* Amazon Linux 2


EC2 instance should be in the same VPC and subnet as key cloak 


**Storage** 

EBS recommended (SSD (gp2) or Provisioned IOPS) 

Size: 250 GB

**Security Group**

| Port | Protocol | Source |
| ---- | -------- | ------ |
| 22 | TCP | 0.0.0.0/0 |
| 80 | TCP | 0.0.0.0/0 |
| 443 | TCP | 0.0.0.0/0 |
| 8850 | TCP | 0.0.0.0/0 |

**EC2 Tags** 
* Name 
* CLAP_OFF	0 17 @ @ 1-5 @
* CLAP_ON	03 7 @ @ 1-5 @
* CT_CLAP_IGNORE
    * Never stop instance

**Userdata bashscript to install yum packages and configure local firewall**

    #!/bin/bash
    yum update -y
    yum install nano wget firewalld openssl cronie -y
    systemctl enable firewalld
    systemctl start firewalld
    firewall-cmd --permanent --add-port={80,443,8850}/tcp
    firewall-cmd --reload
    firewall-cmd --list-all

# Tableau Server Install & Initialize 

[TableauInstall&Initialize](https://help.tableau.com/current/server-linux/en-us/setup.htm)

[TableauServer-Releases](https://www.tableau.com/support/releases/server)


use wget to download tableau server package to server

    wget https://downloads.tableau.com/esdalt/2023.1.7/tableau-server-2023-1-7.x86_64.rpm
    
    sudo yum install tableau-server.rpm -y

    cd /opt/tableau/tableau_server/packages/scripts.20231.23.1011.0410/

    sudo ./initialize-tsm --accepteula --activation-service

The only required parameter for the initialize-tsm script is --accepteula

# Activate Tableau:

[TableauServer-Activation](https://help.tableau.com/current/server-linux/en-us/activate.htm)

No license use 2 week free trial:

    tsm licenses activate -t

[TableauServer-CustomerPortal](https://www.tableau.com/tableau-login-hub)

    tsm licenses activate -k 1234-5768-9999-1236 #activate a license

# Tableau Server Registration

create or transfer registration json file  

[json file template](https://help.tableau.com/current/server-linux/en-us/activate.htm)

    tsm register -f registration.json

# Identity Store Configuration

[Local Identity store settings file template](https://help.tableau.com/current/server-linux/en-us/entity_identity_store.htm)

import file or create local settings file, apply changes

    tsm settings import -f local.json

    tsm pending-changes apply

# Initialize & Add Adminstrator

Initialize Server:

    tsm initialize --start-server --request-timeout 1800

Create initial user:

    tabcmd initialuser --server http://localhost --username 'tabadmin'

# Configure SSL 

Generate self-signed certificate: 

    openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out dev.crt -keyout dev.key

Configure SSL

    tsm security external-ssl enable --cert-file dev.crt --key-file dev.key 

    tsm pending-changes apply


4096 bit rsa key, x509 certificate, 256-bit Secure Hash Algorithm, certified for 1 year, creates key without a passphrase, spciefy filename of certificate, specify key filename

# Tableau Server Web UI

In order to use TSM Web UI, create user and add to tsmadmin group and apply SSL certificates to server

    useradd xadmin

    passwd xadmin

add xadmin to tsmadmin group

    sudo usermod -G tsmadmin -a xadmin

Exit out of current shell and reopen to have updated shell


To continue installing Tableau using the TSM Web Interface (GUI):

https://ip-ipaddress.ec2.internal:8850

http://ip-address:8850

# Cron jobs to start and stop TSM

    sudo systemctl enable crond.service
    sudo systemctl start crond.service
    echo -e '#!/bin/bash\nsudo yum update -y\ntsm start' > start.sh
    echo -e '#!/bin/bash\ntsm stop' > stop.sh
    chmod +x start.sh
    chmod +x stop.sh
    touch backup.log
    touch backup1.log

Execute tsm start up script

    00 8 * * 1-5 /home/ec2-user/start.sh > /home/ec2-user/backup1.log 2>&1

Execute tsm stop script monday - friday and redirect output to log file

    30 16 * * 1-5 /home/ec2-user/stop.sh > /home/ec2-user/backup.log 2>&1

Other cron commands

    #crontab -e #crontab editor
    #pgrep cron #check if cron is working

# Setting Up Initial user in Keycloak and Tableau Server

After creating administrator account, login into Tableau Server using the private IP adddress and the administrator account credentials created.

Create users on Tableau Server, username should be in email format (ex. Tableauadmin@local.net)

Login into Keycloak Realm for Tableau, add users and include email value for the users (ex. tableauadmin@local.net), username doesn't need to be an email on keycloak

Tableau by default maps users' email claim from the identity provider (Keycloak) to users' username in Tableau Server. (keycloak user's email == Tableau user's username)

Integrate Tableau Server with KeyCloak

[OpenIDConnect-Settings](https://help.tableau.com/current/server-linux/en-us/entity_openid.htm)

Edit the values, then run:

    tsm settings import -f identity.json

    tsm pending-changes apply

# Troubleshooting OpenID Connect:
[TroubleshootOIDC](https://help.tableau.com/current/server/en-us/openid_auth_troubleshooting.htm)

[Deactivate-Licenses](https://help.tableau.com/current/server/en-us/license_deactivate.htm)

    tsm licenses list 

    tsm licenses deactivate --license-key <product-key>

    tsm pending-changes apply

    tsm restart

# Installing Database Drivers

[DriverDownload](https://www.tableau.com/support/drivers)

    wget https://download.oracle.com/otn-pub/otn_software/jdbc/233/ojdbc11.jar
    mkdir -vp /opt/tableau/tableau_driver/jdbc
    mv ojdbc11.jar /opt/tableau/tableau_driver/jdbc

# Yum Package Management

    #check version of a package
    locate -b -e -r'^commons-text.*.jar$'
    yum remove nano
    yum info nano 
    yum list installed 

# Optional

* set system hostname
* [Change-token-claim](https://help.tableau.com/current/server-linux/en-us/cli_authentication_tsm.htm#TSMOIDC)

    tsm authentication openid map-claims -un username

