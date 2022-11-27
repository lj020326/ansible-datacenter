#!/usr/bin/env bash

## ref: https://askubuntu.com/questions/611580/how-to-check-the-password-entered-is-a-valid-password-for-this-user

read -p "Username >" username
IFS= read -p "Password >" password
salt=$(sudo getent shadow $username | cut -d$ -f3)
epassword=$(sudo getent shadow $username | cut -d: -f2)
match=$(python -c 'import crypt; print crypt.crypt("'"${password}"'", "$6$'${salt}'")')
[ ${match} == ${epassword} ] && echo "Password matches" || echo "Password doesn't match"
