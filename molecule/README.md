
# Tests

## To sync the latest image version

```shell
$ docker-image-sync.sh redhat8-systemd-python
```

## Create molecule container

```shell
$ MOLECULE_IMAGE_NAMESPACE=lj020326 \
  MOLECULE_IMAGE=centos8-systemd-python \
  molecule --debug create -s bootstrap-linux
```

## Converge molecule container

```shell
$ MOLECULE_IMAGE_NAMESPACE=lj020326 \
  MOLECULE_IMAGE=centos8-systemd-python \
  molecule --debug converge -s bootstrap-linux --destroy never
```

## Test molecule container

```shell
$ MOLECULE_IMAGE_NAMESPACE=lj020326 \
  MOLECULE_IMAGE=centos8-systemd-python \
  molecule --debug test -s bootstrap-linux --destroy never
```

## Run molecule test

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
## do this will reset any prior instance state(s) such that converge should create new instance
## ref: https://github.com/ansible-community/molecule/issues/3094#issuecomment-1157865556
$ molecule destroy --all
$ export MOLECULE_IMAGE=redhat8-systemd-python
$ molecule create
$ molecule login
$ molecule --debug test -s bootstrap-linux-package
```

### converge/test on role 'bootstrap-linux'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_IMAGE=redhat8-systemd-python molecule converge -s bootstrap-linux
$ MOLECULE_IMAGE=redhat8-systemd-python molecule destroy -s bootstrap-linux
$ MOLECULE_IMAGE=redhat8-systemd-python molecule test -s bootstrap-linux --destroy never
$ molecule destroy
```

### converge/test on role 'bootstrap-linux-package'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_IMAGE=redhat8-systemd-python molecule create
$ MOLECULE_IMAGE=redhat8-systemd-python molecule --debug test -s bootstrap-linux-package --destroy never
$ MOLECULE_IMAGE=redhat8-systemd-python molecule login
$ molecule destroy
```

### converge/test on role 'bootstrap-linux-docker'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_IMAGE=redhat8-systemd-python molecule create
$ MOLECULE_IMAGE=redhat8-systemd-python molecule --debug test -s bootstrap-linux-docker --destroy never
$ MOLECULE_IMAGE=redhat8-systemd-python molecule login
$ MOLECULE_IMAGE=redhat8-systemd-python molecule destroy -s bootstrap-linux-docker
$ MOLECULE_IMAGE=centos7-systemd-python molecule converge --destroy never
$ MOLECULE_IMAGE=centos7-systemd-python molecule login
$ molecule destroy --all
$ MOLECULE_IMAGE=centos8-systemd-python --debug converge
$ molecule destroy --all
$ MOLECULE_IMAGE=ubuntu2004-systemd-python converge
$ molecule destroy --all
$ MOLECULE_IMAGE=ubuntu2204-systemd-python --debug converge

```

To log into container

```shell
$ molecule create
$ molecule login
```

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 converge
$ molecule destroy
$ tests/molecule_exec.sh debian8 converge
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge

```

```shell
MOLECULE_DISTRO=centos7-systemd-python molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=centos7-systemd-python molecule --debug create -s bootstrap-linux
MOLECULE_DISTRO=centos7-systemd-python molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=centos7-systemd-python molecule --debug test -s bootstrap-linux
MOLECULE_DISTRO=centos7-systemd-python molecule --debug test -s bootstrap-linux --destroy never
MOLECULE_DISTRO=centos7-systemd-python molecule --debug verify -s bootstrap-linux
MOLECULE_DISTRO=centos7-systemd-python molecule --debug verify -s bootstrap-linux --destroy never
MOLECULE_DISTRO=centos8-systemd-python molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=centos8-systemd-python molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=centos8-systemd-python molecule --debug test -s bootstrap-linux --destroy never
MOLECULE_DISTRO=centos8-systemd-python molecule destroy --all
MOLECULE_DISTRO=debian9-systemd-python MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=debian9-systemd-python MOLECULE_DOCKER_COMMAND=/usr/sbin/init molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=debian9-systemd-python molecule --debug -s bootstrap-linux destroy --all
MOLECULE_DISTRO=debian9-systemd-python molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=debian9-systemd-python molecule --debug destroy --all -s bootstrap-linux
MOLECULE_DISTRO=debian9-systemd-python molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=debian9-systemd-python molecule --debug destroy -s bootstrap-linux destroy
MOLECULE_DISTRO=lj020326/centos8-systemd-python molecule --debug create -s bootstrap-linux
MOLECULE_DISTRO=lj020326/centos8-systemd-python molecule --debug create -s bootstrap-linux --destroy never
MOLECULE_DISTRO=redhat8-systemd-python MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug -s bootstrap-linux converge
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug converge --all -s bootstrap-linux
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug converge -s bootstrap-linux-docker --destroy never
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug create -s bootstrap-linux
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug destroy --all
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug destroy --all -s bootstrap-linux
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug destroy --all -s bootstrap-linux-docker
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug destroy -s bootstrap-linux-docker
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux --destroy never
MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-docker --destroy never
MOLECULE_DISTRO=redhat8-systemd-python molecule create
MOLECULE_DISTRO=redhat8-systemd-python molecule destroy
MOLECULE_DISTRO=redhat8-systemd-python molecule destroy --all
MOLECULE_DISTRO=redhat8-systemd-python molecule login
MOLECULE_DISTRO=ubuntu22-systemd-python molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=ubuntu2204-systemd-python molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=ubuntu2204-systemd-python molecule destroy
MOLECULE_DISTRO=ubuntu2204-systemd-python molecule destroy --all
MOLECULE_IMAGE=centos8-systemd-python molecule --debug destroy -s bootstrap-linux
MOLECULE_IMAGE_NAMESPACE=lj020326 MOLECULE_DISTRO=centos8-systemd-python molecule --debug create -s bootstrap-linux
MOLECULE_IMAGE_NAMESPACE=lj020326 MOLECULE_DISTRO=centos8-systemd-python molecule --debug test -s bootstrap-linux --destroy never
ansible-galaxy collection install -vvv -fr collections/requirements.molecule.yml 
cat requirements.molecule.txt 
echo $MOLECULE_DISTRO
echo $MOLECULE_IMAGE_NAMESPACE
molecule --version
molecule destroy
molecule destroy --all
molecule/docker-image-sync.sh centos7-systemd-python
molecule/docker-image-sync.sh centos8-systemd-python
molecule/docker-image-sync.sh centos8-systemd-python hub.docker.com
molecule/docker-image-sync.sh centos8-systemd-python registry.hub.docker.com
molecule/docker-image-sync.sh lj020326/centos8-systemd-python registry.hub.docker.com
molecule/docker-image-sync.sh redhat8-systemd-python
```
