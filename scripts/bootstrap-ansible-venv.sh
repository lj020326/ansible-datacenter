#!/usr/bin/env bash

#VENV_PYTHON_INTERPRETER="/usr/bin/python"
VENV_PYTHON_INTERPRETER="/usr/bin/python3"

#echo "Preparing the kolla env..."
### ref: https://docs.openstack.org/project-deploy-guide/kolla-ansible/latest/quickstart.html
#${SUDO_CMD} mkdir -p /etc/kolla
#
### copy only if not present already
#${SUDO_CMD} cp -npr venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla

#VENV_COMMAND="virtualenv --system-site-packages venv"
#VENV_COMMAND="virtualenv --python=${VENV_PYTHON_INTERPRETER} --system-site-packages venv"
VENV_COMMAND="virtualenv --python=${VENV_PYTHON_INTERPRETER} venv"

UNAME=$(uname -s | tr "[:upper:]" "[:lower:]")
SSH_COMMON_ARGS=""
SUDO_CMD="sudo"

FORCE_ARG=""
#FORCE_ARG="--force"

case "${UNAME}" in
linux*)
  PLATFORM=Linux
  ;;
darwin*)
#  VENV_COMMAND="python -m venv --system-site-packages venv"
  VENV_COMMAND="python -m venv venv"
  PLATFORM=DARWIN
  ;;
cygwin* | mingw64* | mingw32* | msys*)
  VENV_COMMAND="python -m venv --system-site-packages venv"
  #      SSH_COMMON_ARGS="ControlMaster=no -o ControlPersist=2m -o ServerAliveInterval=50"
  SUDO_CMD=""
  PLATFORM=MSYS
  ;;
*)
  PLATFORM="UNKNOWN:${UNAME}"
  ;;
esac

if [ ! -d ${ANSIBLE_PLAYBOOK_HOME}/venv ]; then
  echo "Creating python venv..."
  ${VENV_COMMAND}
  if [ $? -ne 0 ]; then
    echo "virtualenv creation failed [$?] quitting ..."
    exit 1
  fi
#    . venv/bin/activate
fi

. venv/bin/activate
pip install --upgrade pip

if [ -f requirements.txt ]; then
  echo "Preparing python venv..."
  pip install -q -r requirements.txt
  #  pip3 install -q -r requirements.txt
  if [ $? -ne 0 ]; then
    echo "pip install into venv failed [$?] quitting ..."
    exit 1
  fi
#  pip_install_result=$(venv/bin/pip install -q -r requirements.txt)
#  echo "pip install results=${pip_install_result}"
fi

INSTALL_GALAXY_REQ=0
if [ -f collections/requirements.yml ]; then
  echo "Installing galaxy collections/requirements.yml..."
  INSTALL_GALAXY_REQ=1
  REQ_FILE=collections/requirements.yml
  ansible-galaxy collection install ${FORCE_ARG} -r ${REQ_FILE}

fi

if [ -f roles/requirements.yml ]; then
  echo "Installing galaxy roles/requirements.yml..."
  INSTALL_GALAXY_REQ=1
  REQ_FILE=roles/requirements.yml
elif [ -f requirements.yml ]; then
  echo "Installing galaxy requirements.yml..."
  INSTALL_GALAXY_REQ=1
  REQ_FILE=requirements.yml
elif [ -f ansible-role-requirements.yml ]; then
  echo "Installing galaxy ansible-role-requirements.yml..."
  INSTALL_GALAXY_REQ=1
  REQ_FILE=ansible-role-requirements.yml
fi

if [ ${INSTALL_GALAXY_REQ} -gt 0 ]; then
  ## 	How to install both roles and collections at same time:
  ##		ref: https://docs.ansible.com/ansible/latest/user_guide/collections_using.html
  ansible-galaxy install ${FORCE_ARG} -r ${REQ_FILE}

  #  ansible-galaxy role install ${FORCE_ARG} -r ${REQ_FILE}
  ansible-galaxy collection install ${FORCE_ARG} -r ${REQ_FILE}
#  galaxy_install_result=$(venv/bin/ansible-galaxy install ${FORCE_ARG} -r ${REQ_FILE})
#  echo "galaxy install results=${galaxy_install_result}"
fi

echo "Finished bootstrapping the ansible env!"
