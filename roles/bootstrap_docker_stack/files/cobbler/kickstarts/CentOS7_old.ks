## ref: https://hostpresto.com/community/tutorials/how-to-install-and-configure-cobbler-on-centos-7/
##

#platform=x86, AMD64, or Intel EM64T
#version=DEVEL

# Firewall configuration
firewall --disabled

# Install OS instead of upgrade
install

# Use HTTP installation media
url --url="http://172.168.10.5/cblr/links/CentOS7-x86_64/"

# Root password
rootpw --iscrypted $1$j9/aR8Et$uovwBsGM.cLGcwR.Nf7Qq0

# Network information
network --bootproto=dhcp --device=eth0 --onboot=on

# Reboot after installation
reboot

# System authorization information
auth useshadow passalgo=sha512

# Use graphical install
graphicalfirstboot disable

# System keyboard
keyboard us

# System language
lang en_US

# SELinux configuration
selinux disabled

# Installation logging level
logging level=info

# System timezone
timezone Europe/Amsterdam

# System bootloader configuration
bootloader location=mbrclearpart --all --initlabel
part swap --asprimary --fstype="swap" --size=1024
part /boot --fstype xfs --size=500
part pv.01 --size=1 --grow
volgroup root_vg01 pv.01
logvol / --fstype xfs --name=lv_01 --vgname=root_vg01 --size=1 --grow%packages
@^minimal@core
%end
%addon com_redhat_kdump --disable --reserve-mb='auto'
%end
