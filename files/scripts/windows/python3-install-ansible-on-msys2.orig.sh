#!/usr/bin/env bash

## ref: https://gist.github.com/DaveB93/db94a6b310e08c928c0778f766562ab0
## ref: https://git.scc.kit.edu/ansible-windows/msys2-ansible

which ansible >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Installing Ansible..."
  sleep 5
  pushd .
  cd ~
  pacman -S libyaml-devel python3 python3-pip mingw-w64-x86_64-libsodium libffi libffi-devel gcc pkg-config make openssl-devel openssh libcrypt-devel --noconfirm --needed
  SODIUM_INSTALL=system CFLAGS=`pkg-config --cflags libffi` LDFLAGS=`pkg-config --libs libffi` python3 -m pip install cffi --no-binary :all:
  SODIUM_INSTALL=system CFLAGS=`pkg-config --cflags libffi` LDFLAGS=`pkg-config --libs libffi` C_INCLUDE_PATH=/mingw64/include LIBRARY_PATH=/mingw64/lib python3 -m pip install pynacl
  python3 -m pip install ansible --no-binary :all:
  popd
fi

which ansible >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Ansible installed."
else
  echo "Ansible not installed."
fi
