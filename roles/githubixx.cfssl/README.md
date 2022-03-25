ansible-role-cfssl
==================

Installes CFSSL (CloudFlare's PKI toolkit) binaries. I used it as a lightweight certificate authority (CA) for Kubernetes. This Ansible playbook is used in [Kubernetes the not so hard way with Ansible - certificate authority](https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/).

Versions
--------

I tag every release and try to stay with [semantic versioning](http://semver.org). If you want to use the role I recommend to checkout the latest tag. The master branch is basically development while the tags mark stable releases. But in general I try to keep master in good shape too.

The tag `7.1.0+1.6.0` means that this is the release `7.1.0` of the Ansible role which uses release `1.6.0` of CFSSL.

Changelog
---------

see [CHANGELOG.md](https://github.com/githubixx/ansible-role-cfssl/blob/master/CHANGELOG.md)

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

License
-------

GNU GENERAL PUBLIC LICENSE Version 3

Author Information
------------------

http://www.tauceti.blog
