#!/bin/bash

## source: https://gist.github.com/simonkuang/14abf618f631ba3f0c7fee7b4ea3f214

sudo yum install -y epel-release
sudo yum install -y gcc gcc-c++ glibc glibc-devel curl git \
    libffi-devel sqlite-devel bzip2-devel bzip2 readline-devel

sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
#sudo yum install -y zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel

curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | /bin/bash

cat <<EOF >> $HOME/.bashrc

# Load pyenv automatically by adding
# the following to ~/.bash_profile:
export PATH="$HOME/.pyenv/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EOF

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

mkdir -p $HOME/.pyenv/cache
# Python 3
#PYVER=3.7.4
PYVER=3.9.16
#PYVER=3.10.9

curl -Lo "$HOME/.pyenv/cache/Python-$PYVER.tar.xz" \
    "https://registry.npmmirror.com/-/binary/python/$PYVER/Python-$PYVER.tar.xz"
#    "https://npm.taobao.org/mirrors/python/$PYVER/Python-$PYVER.tar.xz"

## ref: https://github.com/pyenv/pyenv/issues/2416
#env CFLAGS=-fPIC pyenv install $PYVER
env CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC pyenv install $PYVER
#env CPPFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib -lssl -lcrypto" CFLAGS=-fPIC pyenv install $PYVER

# Python 2
PYVER=2.7.16
curl -Lo "$HOME/.pyenv/cache/Python-$PYVER.tar.xz" \
    "https://registry.npmmirror.com/-/binary/python/$PYVER/Python-$PYVER.tar.xz"
#    "https://npm.taobao.org/mirrors/python/$PYVER/Python-$PYVER.tar.xz"

env CFLAGS=-fPIC   pyenv install $PYVER
mkdir -p $HOME/.config/pip
[ -f $HOME/.config/pip/pip.conf ] && mv $HOME/.config/pip/pip.conf $HOME/.config/pip/pip.conf.bak

cat <<EOF
 EOF
EOF >> $HOME/.config/pip/pip.conf
# pip.ini (Windows)
# pip.conf (Unix, macOS)

[global]
trusted-host = pypi.org
               files.pythonhosted.org
EOF
#echo '[global]' > $HOME/.config/pip/pip.conf
#echo 'index-url = https://mirrors.aliyun.com/pypi/simple' >> $HOME/.config/pip/pip.conf
#echo '' >> $HOME/.config/pip/pip.conf

pyenv virtualenv $PYVER supervisor
# Done
unset PYVER
