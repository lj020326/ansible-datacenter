#!/usr/bin/python3

# ref: https://www.tutorialspoint.com/python-function-to-check-unix-passwords

import crypt
import getpass
# noinspection PyCompatibility
import spwd


def check_pass():
    username = input("Enter The Username: ")
    password = spwd.getspnam(username).sp_pwdp
    if password:
        clr_text = getpass.getpass()
        return crypt.crypt(clr_text, password) == password
    else:
        return 1


if check_pass():
    print("The password matched")
else:
    print("The password does not match")
