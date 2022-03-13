#!/bin/sh

cat ~/.ssh/id_rsa.pub | ssh root@esx01.dettonville.int "cat >> /etc/ssh/keys-root/authorized_keys"
