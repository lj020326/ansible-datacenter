#!/usr/bin/env bash
VIRTUALENV_PATH=/home/vagrant/.virtualenv
action="$1"
shift

case "$action" in
"install")
    if [ ! -f $VIRTUALENV_PATH/bin/activate ]; then
        echo "[TASK] Installing Ansible dependencies and setting up virtual environment..."
        sudo apt-get update
        sudo apt-get install -y python3-pip python3-dev libffi-dev libyaml-dev libssl-dev build-essential pkg-config git python3-venv
        python3 -m venv $VIRTUALENV_PATH
    fi
    source $VIRTUALENV_PATH/bin/activate
    if [ ! -x $VIRTUALENV_PATH/bin/ansible-playbook ]; then
        echo "[TASK] Installing Ansible..."
        pip install -U pip
        pip install ansible
    fi
    echo "[TASK] Packaging bootstrap_lxc role and installing it in guest..."
    cd /vagrant
    git ls-files -z | xargs -0 tar -czvf bootstrap_lxc.tar.gz #https://stackoverflow.com/a/43909430/4670172
    ansible-galaxy install bootstrap_lxc.tar.gz,devel-$(git rev-parse HEAD),bootstrap_lxc --force
    rm bootstrap_lxc.tar.gz
    ;;
"syntax")
    source $VIRTUALENV_PATH/bin/activate
    echo "[TASK] Performing Ansible role syntax check..."
    cd /vagrant/tests/
    ansible-playbook -i inventory deploy.yml --syntax-check
    ;;
"idempotence")
    source $VIRTUALENV_PATH/bin/activate
    echo "[TASK] Performing idempotency check..."
    cd /vagrant/tests/
    ANSIBLE_STDOUT_CALLBACK=debug unbuffer ansible-playbook -vvi inventory deploy.yml > play.log ||
        (e=$?; echo "Ansible playbook failed to complete. Check tests/play.log."; exit $e)
    printf "Idempotence: "
    grep -A1 "PLAY RECAP" play.log | grep -qP "changed=0 .*failed=0 .*" &&
        (echo "PASS"; exit 0) ||
        (echo "FAIL"; echo "Check tests/play.log for more information."; exit 1)
    ;;
esac
