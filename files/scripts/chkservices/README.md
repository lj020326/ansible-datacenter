System requirements
=====
- CentOS 6.x or RedHat like

- yum install mailx

- postfix or other MTA running

Install
=====

wget https://raw.githubusercontent.com/surfingtux/chkservices/master/download/chkservices.tgz

tar xvf chkservices.tgz

cd chkservices

./install.sh


Configuration
=====

vim /etc/chkservices/chkservices.conf


Enable startup and service management
=====

chkconfig chkservices on

service chkservices start/stop

Next Systems - systemd
=====
For CentOS 7.x and newer, use systemd configuration:
https://wiki.archlinux.org/index.php/Systemd
