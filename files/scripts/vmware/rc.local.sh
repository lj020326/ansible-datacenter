#!/bin/sh

export PATH=/sbin:/bin

log() {
   echo "${1}"
   /bin/busybox logger init "${1}"
}

# execute all service retgistered in ${rcdir} ($1 or /etc/rc.local.d)
if [ -d "${1:-/etc/rc.local.d}" ] ; then
   for filename in $(find "${1:-/etc/rc.local.d}" | /bin/busybox sort) ; do
      if [ -f "${filename}" ] && [ -x "${filename}" ]; then
         log "running ${filename}"
         "${filename}"
      fi
   done
fi

mkdir /.ssh
cat > /.ssh/authorized_keys << __SSH_KEYS__
ssh-rsa 000000000000000000000000 admin@example.com
__SSH_KEYS__

chmod 600 /.ssh/authorized_keys
cp -p /.ssh/authorized_keys /etc/ssh/keys-root
/etc/init.d/SSH restart


## source: https://raw.githubusercontent.com/chrisipa/packer-esxi/master/local.sh

# local configuration options

# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.

# enable guest ip hack
esxcli system settings advanced set -o /Net/GuestIPHack -i 1

# configuration
firewallConfigFile="/etc/vmware/firewall/service.xml"

# change permissions on firewall config file
chmod 644 "$firewallConfigFile"
chmod +t "$firewallConfigFile"

# remove config root end tag from firewall config file
sed -i -e 's|</ConfigRoot>||g' "$firewallConfigFile"

# add xml block for vnc ports to the end of the firewall config file
cat <<EOT >> "$firewallConfigFile"
  <!-- Ports opened for Packer VNC commands -->
  <service id="1000">
    <id>packer-vnc</id>
    <rule id="0000">
      <direction>inbound</direction>
      <protocol>tcp</protocol>
      <porttype>dst</porttype>
      <port>
        <begin>5900</begin>
        <end>6000</end>
      </port>
    </rule>
    <enabled>true</enabled>
    <required>true</required>
  </service>
</ConfigRoot>
EOT

# restore permissions on firewall config file
chmod 444 "$firewallConfigFile"

# restart firewall service
esxcli network firewall refresh

exit 0
