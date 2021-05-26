#!/usr/bin/env bash

## ref: https://wiki.fogproject.org/wiki/index.php/Uninstall_FOG

#Uninstall FOG

#remove service
sudo rm /etc/init.d/FOGImageReplicator
sudo rm /etc/init.d/FOGMulticastManager
sudo rm /etc/init.d/FOGScheduler

#delete fog database
#sudo mysql
##(or 'sudo mysql -p' if you set a root password for mysql)
#drop database fog;
#quit
#
sudo mysql -u root -e "drop database fog"

#Remove files
sudo rm -rf /var/www/fog
sudo rm -rf /var/www/html/fog
sudo rm -rf /opt/fog
sudo rm -rf /tftpboot
sudo rm -rf /images #Warning, this line deletes any existing images.

#delete fog system user
sudo userdel fog
