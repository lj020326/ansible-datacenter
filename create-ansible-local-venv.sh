#!/bin/bash -eux

VENV_DIR="${HOME}/.venv/ansible"

__PIP_VERSION="${PIP_VERSION:-"latest"}"

## ref: https://liquidat.wordpress.com/2019/08/30/howto-get-a-python-virtual-environment-running-on-rhel-8/
echo "==> Configuring ansible environment for pip version ${__PIP_VERSION}"
#python3 -m venv "${VENV_DIR}"
python3 -m venv --system-site-packages "${VENV_DIR}"

PYTHON_CMD="${VENV_DIR}/bin/python3"

#PIP_INSTALL_CMD_USER="${VENV_DIR}/bin/pip3 install --user --upgrade --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org"
#PIP_INSTALL_CMD="${VENV_DIR}/bin/pip3 install --upgrade --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org"

#PIP_INSTALL_CMD_USER="${VENV_DIR}/bin/pip3 install --user --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org"
PIP_INSTALL_CMD="${VENV_DIR}/bin/pip3 install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org"

## ref: https://stackoverflow.com/questions/6141581/detect-python-version-in-shell-script#6141633
PYTHON_VERSION=$(${PYTHON_CMD} -c 'import sys; version=sys.version_info[:2]; print("{0}.{1}".format(*version))')

echo "==> Install latest ansible"
### ref: http://www.freekb.net/Article?id=214
### ref: https://github.com/pyca/pyopenssl/issues/559
##${PIP_INSTALL_CMD} pip ansible virtualenv cryptography pyopenssl
##${PIP_INSTALL_CMD} pip ansible cryptography pyopenssl
#${PIP_INSTALL_CMD} wheel
#${PIP_INSTALL_CMD} setuptools_rust
##${PIP_INSTALL_CMD} cryptography
##${PIP_INSTALL_CMD} pyopenssl

if [ "${__PIP_VERSION}" == "latest" ]; then
  ## ref: https://stackoverflow.com/questions/65985221/pip-upgrade-issue-using-python-m-pip-install-upgrade-pip
  if [ "${PYTHON_VERSION}" == "3.6" ]; then
    wget -O /tmp/get-pip.py --no-verbose --no-check-certificate https://bootstrap.pypa.io/pip/3.6/get-pip.py
    ${PYTHON_CMD} /tmp/get-pip.py
  elif [ "${PYTHON_VERSION}" == "2.7" ]; then
    wget -O /tmp/get-pip.py --no-verbose --no-check-certificate https://bootstrap.pypa.io/pip/2.7/get-pip.py
    ${PYTHON_CMD} /tmp/get-pip.py
  else
    wget -O /tmp/get-pip.py --no-verbose --no-check-certificate https://bootstrap.pypa.io/get-pip.py
    ${PYTHON_CMD} /tmp/get-pip.py
  fi
  ${PIP_INSTALL_CMD} --upgrade pip
else
  ${PIP_INSTALL_CMD} --upgrade pip=="${__PIP_VERSION}"
fi

${PIP_INSTALL_CMD} ansible

########
## pip libs required for dcc_common.util.apply_common_group
${PIP_INSTALL_CMD} netaddr
${PIP_INSTALL_CMD} jmespath

#echo "export PATH=$PATH:~/.local/bin" >> ~/.bash_profile

#echo "==> Install upgraded ansible collections"
#export PATH=$PATH:/usr/local/bin
#ansible-galaxy collection install -U ansible.utils
#ansible-galaxy collection install -U community.general

if [[ ! -z ${ANSIBLE_VAULT_PASS+x} ]]; then
  echo "==> Setup ansible ~/.vault_pass"
  echo "${ANSIBLE_VAULT_PASS}" > ~/.vault_pass
  chmod 600 ~/.vault_pass
fi
