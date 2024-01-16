#!/bin/bash
#only for spel-minimal amis
#spel-minimal-rhel-7-hvm-2023.10.1.x86_64-gp2
sudo growpart /dev/nvme0n1 2
sudo pvresize /dev/nvme0n1p2
sudo lvextend -L +5G /dev/VolGroup00/rootVol
sudo lvextend -L +5G /dev/VolGroup00/homeVol
sudo lvextend -L +5G /dev/VolGroup00/logVol
sudo lvextend -L +200G /dev/VolGroup00/varVol
sudo resize2fs /dev/VolGroup00/rootVol
sudo resize2fs /dev/VolGroup00/homeVol
sudo resize2fs /dev/VolGroup00/logVol
sudo resize2fs /dev/VolGroup00/varVol
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port={80,443,8850}/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all


#sudo firewall-cmd --permanent --add-port=80/tcp
#sudo firewall-cmd --permanent --add-port=443/tcp
#sudo firewall-cmd --permanent --add-port=8850/tcp
