bootstrap_cfssl
==================

Installes CFSSL (CloudFlare's PKI toolkit) binaries. I used it as a lightweight certificate authority (CA) for Kubernetes. This Ansible playbook is used in [Kubernetes the not so hard way with Ansible - certificate authority](https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/).


Role Variables
--------------

```
# Specifies the version of CFSSL toolkit we want to download and use
cfssl_version: "1.6.1"

# Checksum file
cfssl_checksum_url: "https://github.com/cloudflare/cfssl/releases/download/v{{ cfssl_version }}/cfssl_{{ cfssl_version }}_checksums.txt"

# The directory where CFSSL binaries will be installed
cfssl_bin_directory: "/usr/local/bin"

# Owner of the cfssl binaries
cfssl_owner: "root"

# Group of cfssl binaries
cfssl_group: "root"

# Operarting system on which "cfssl/cfssljson" should run on
cfssl_os: "linux" # use "darwin" for MacOS X, "windows" for Windows

# Processor architecture "cfssl/cfssljson" should run on
cfssl_arch: "amd64" # the only supported architecture at the moment
```

Testing
-------

This role has a small test setup that is created using [molecule](https://github.com/ansible-community/molecule). To run the tests follow the molecule [install guide](https://molecule.readthedocs.io/en/latest/installation.html). Also ensure that a Docker daemon runs on your machine.

Assuming [Docker](https://www.docker.io) is already installed you need at least two Python packages:

```
pip3 install --user molecule
pip3 install --user molecule-docker
```

Afterwards molecule can be executed:

```
molecule converge
```

This will setup some Docker container with Ubuntu 18.04/20.04 and Debian 10/11 with `cfssl` installed.

To clean up run

```
molecule destroy
```

Example Playbook
----------------

```
- hosts: cfssl-hosts
  roles:
    - githubixx.cfssl
```
