#!/bin/sh

## source: http://pig.made-it.com/ldap-openssh.html#29273
ldapsearch -x '(&(objectClass=ldapPublicKey)(uid='"$1"'))' 'sshPublicKey' | \
    sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;s/sshPublicKey: //gp'
