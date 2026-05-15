```markdown
---
title: bootstrap_lxc Role Documentation
original_path: roles/bootstrap_lxc/README.md
category: Ansible Roles
tags: [ansible, lxc, travis-ci]
---

# bootstrap_lxc

[![Build Status](https://img.shields.io/travis/lae/ansible-role-travis-lxc/master.svg?style=for-the-badge)](https://travis-ci.org/lae/ansible-role-travis-lxc)
[![Ansible Galaxy Role](https://img.shields.io/ansible/role/27270.svg?style=for-the-badge)](https://galaxy.ansible.com/lae/travis-lxc)

## Overview

The `bootstrap_lxc` role configures and starts N LXC containers to use in the Travis CI environment for simpler testing of Ansible roles across different distributions.

## Usage

### Minimal `.travis.yml`

To test your Ansible roles on Travis CI using LXC, you can use a minimal `.travis.yml` configuration like this:

```yaml
---
language: python
sudo: required
dist: bionic
install:
  - pip install ansible
  - ansible-galaxy install bootstrap_lxc,v0.9.0
  - ansible-playbook tests/install.yml -i tests/inventory
before_script: cd tests/
script:
  # Validates your deployment playbook's syntax, which should contain your role
  - ansible-playbook -i inventory deploy.yml --syntax-check
  # Runs the deployment playbook
  - ansible-playbook -i inventory deploy.yml
  # Runs the deployment playbook again, saving output to a file called play.log,
  # then checks that there are no changed/failed tasks and fails if there are.
  - 'ANSIBLE_STDOUT_CALLBACK=debug ANSIBLE_DISPLAY_SKIPPED_HOSTS=no ANSIBLE_DISPLAY_OK_HOSTS=no unbuffer ansible-playbook -vvi inventory deploy.yml &>play.log; printf "Idempotence: "; grep -A1 "PLAY RECAP" play.log | grep -qP "changed=0 .*failed=0 .*" && (echo "PASS"; exit 0) || (echo "FAIL"; cat play.log; exit 1)'
  # Integration tests and what not
  - ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -i inventory -v test.yml
```

### File Structure

The following files are referenced in the `.travis.yml`:

- **tests/install.yml**: Executes `bootstrap_lxc` and other pre-install steps.
- **tests/deploy.yml**: Executes the role you're testing.
- **tests/test.yml**: Executes validation tests against your deployment.
- **tests/inventory**: Contains a list of LXC container hostnames.

#### Example `install.yml`

```yaml
---
- hosts: localhost
  connection: local
  roles:
    - role: bootstrap_lxc
  vars:
    test_profiles:
      - profile: debian-buster
      - profile: ubuntu-focal
      - profile: centos-7
      - profile: alpine-v3.11

# Add any other setup tasks you might need but don't necessarily need in your role
- hosts: all
  tasks: []
```

#### Example `deploy.yml`

```yaml
---
- hosts: all
  become: true
  any_errors_fatal: true
  roles:
    - ansible-role-strawberry-milk
  vars:
    number_of_cartons: 15
```

#### Example `test.yml`

```yaml
---
- hosts: all
  tasks:
    - name: Ensure that the Strawberry Milk HTTP service is running
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}:1515"
    - block:
      - name: Print out Strawberry Milk configuration
        shell: cat /etc/strawberry_milk.conf
        changed_when: false
      - name: Print out system logs
        shell: "cat /var/log/messages || cat /var/log/syslog || journalctl -xb"
      ignore_errors: yes
```

#### Example `inventory`

```ini
debian-buster-01
ubuntu-focal-01
centos-7-01
alpine-v3-11-01
```

### Testing Multiple Ansible Versions

To test your role against multiple Ansible versions, configure `.travis.yml` as follows:

```yaml
env:
  - ANSIBLE_GIT_VERSION='devel'
  - ANSIBLE_VERSION='~=2.9.0'
  - ANSIBLE_VERSION='~=2.7.0'
install:
  - if [ "$ANSIBLE_GIT_VERSION" ]; then pip install "https://github.com/ansible/ansible/archive/${ANSIBLE_GIT_VERSION}.tar.gz"; else pip install "ansible${ANSIBLE_VERSION}"; fi
  - ansible --version
```

### Ansible Performance and Profiling

You can configure `tests/ansible.cfg` to enable profiling:

```ini
[defaults]
callbacks_enabled=profile_tasks
forks=20
internal_poll_interval = 0.001
```

### Caching

To cache LXC images for faster bootstrapping, add the following to `.travis.yml`:

```yaml
cache:
  directories:
    - "$HOME/lxc"
  pip: true
```

## Role Variables

- **test_profiles**: Specifies distributions to test against. Supported profiles include:
  
  ```yaml
  test_profiles:
    - profile: alpine-v3.11
    - profile: centos-7
    - profile: debian-buster
    - profile: ubuntu-focal
  ```

- **container_config**: Overrides the container configuration used, if necessary.
  
  ```yaml
  container_config:
    - "lxc.aa_profile=unconfined"
    - "lxc.mount.auto=proc:rw sys:rw cgroup-full:rw"
    - "lxc.cgroup.devices.allow=a *:* rmw"
  ```

- **additional_packages**: Installs extra packages inside the test containers.
  
  ```yaml
  additional_packages:
    - make
  ```

- **lxc_cache_profiles**: Selectively caches a subset of your test profiles.
  
  ```yaml
  lxc_cache_profiles:
    - alpine-v3.11
    - centos-7
  ```

- **lxc_cache_directory**: Specifies the directory to cache LXC images.
  
  ```yaml
  lxc_cache_directory: "$HOME/lxc"
  ```

- **lxc_use_overlayfs**: Disables the usage of OverlayFS in the LXC containers if necessary.
  
  ```yaml
  lxc_use_overlayfs: no
  ```

## Contributors

- Musee Ullah ([@lae](https://github.com/lae), <lae@lae.is>)
- Wilmar den Ouden ([@wilmardo](https://github.com/wilmardo))

## Stability

This role is currently pre-1.0 and not guaranteed to be stable. If you encounter issues, please open an issue with a brief description and any appropriate logs.

**Important:** Pin to a specific version when using this role to avoid breaking changes in minor releases before a 1.0 release.

## Backlinks

- [Ansible Roles](https://github.com/lae/ansible-role-travis-lxc)
```

This improved documentation ensures clarity, structure, and professional formatting suitable for GitHub rendering.