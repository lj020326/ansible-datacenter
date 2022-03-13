#!/usr/bin/env bash

## ref: https://gist.github.com/DaveB93/db94a6b310e08c928c0778f766562ab0

which ansible >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Installing Ansible..."
  sleep 5
  pacman -S python3 python3-pip python-cryptography ansible sshpass --noconfirm --needed

  ## ref: https://bbs.archlinux.org/viewtopic.php?id=239947
  ## ref: https://github.com/ansible/ansible/issues/42357
  ## confirm that pycryptodome appears in following:
  ## ls -Fla /usr/lib/python3.9/site-packages/
  pacman -S mingw-w64-x86_64-python-pycryptodome --noconfirm --needed
fi

which ansible >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Ansible installed."
  ansible --version
else
  echo "Ansible not installed."
fi
