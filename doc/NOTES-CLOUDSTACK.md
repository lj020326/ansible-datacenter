## ref: https://github.com/fernandohackbart/ansible-cloudstack-centos/blob/master/doc/procedure.txt

virsh destroy cloudstack1;virsh undefine cloudstack1;rm -rf /opt/cloudstack/guests/cloudstack1/

mkdir -p /opt/cloudstack/guests/cloudstack1/

virt-install \
 -n cloudstack1 \
 --description="Cloudstack 1" \
 --os-type=Linux \
 --os-variant=generic \
 --ram=2048 \
 --vcpus=1 \
 --graphics=vnc \
 --noautoconsole \
 --disk path=/opt/cloudstack/guests/cloudstack1/cloudstack1.img,bus=virtio,size=10 \
 --pxe \
 --boot=hd,network \
 --network=bridge:dcos-br0,model=virtio,mac=52:54:00:e2:87:91
  
ssh root@192.168.40.91

# http://docs.cloudstack.apache.org/projects/cloudstack-installation/en/4.9/management-server/index.html

cat > /etc/yum.repos.d/cloudstack.repo <<EOF
[cloudstack]
name=cloudstack
baseurl=http://cloudstack.apt-get.eu/centos/7/4.10/
enabled=1
gpgcheck=0
EOF

yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
yum install -y cloudstack-management
yum install -y mysql-server
yum -y update


reboot

ln -s /etc/cloudstack/management/commons-logging.properties /etc/cloudstack/management/logging.properties

vi /etc/my.cnf

innodb_rollback_on_timeout=1
innodb_lock_wait_timeout=600
max_connections=350
log-bin=mysql-bin
binlog-format = 'ROW'

systemctl start mysql
systemctl enable mysql
mysql_secure_installation



cloudstack-setup-databases cloud:Welcome1@localhost --deploy-as=root:Welcome1 -m Welcome1 -k Welcome1 

cat >> /etc/sudoers <<EOF
Defaults:cloud !requiretty
EOF

cloudstack-setup-management --tomcat7


yum install nfs-utils


mkdir -p /export/primary
mkdir -p /export/secondary

cat > /etc/exports <<EOF
/export  *(rw,async,no_root_squash,no_subtree_check)
EOF

exportfs -a

cat >> /etc/sysconfig/nfs <<EOF
LOCKD_TCPPORT=32803
LOCKD_UDPPORT=32769
MOUNTD_PORT=892
RQUOTAD_PORT=875
STATD_PORT=662
STATD_OUTGOING_PORT=2020
EOF

vi /etc/idmapd.conf

Domain = prototype.local


systemctl start rpcbind
systemctl start nfs
systemctl enable rpcbind
systemctl enable nfs
