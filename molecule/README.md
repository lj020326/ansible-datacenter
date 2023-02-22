
# Tests

## To sync the latest image version

```shell
$ docker-image-sync.sh redhat8-systemd-python
```

## Create molecule container

```shell
$ MOLECULE_DISTRO=centos8 \
  molecule --debug create -s bootstrap-linux
```

## Converge molecule container

```shell
$ MOLECULE_DISTRO=centos8 \
  molecule --debug converge -s bootstrap-linux
```

## Test molecule container

```shell
$ MOLECULE_DISTRO=centos8 \
  molecule --debug test -s bootstrap-linux --destroy never
```

## Run molecule test

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
## do this will reset any prior instance state(s) such that converge should create new instance
## ref: https://github.com/ansible-community/molecule/issues/3094#issuecomment-1157865556
$ molecule destroy --all
$ export MOLECULE_DISTRO=redhat8
$ molecule create
$ molecule login
$ molecule --debug test -s bootstrap-linux-package
```

### converge/test on role 'bootstrap-linux'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_DISTRO=redhat8 molecule converge -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule destroy -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule test -s bootstrap-linux --destroy never
$ molecule destroy
```

### converge/test on role 'bootstrap-linux-package'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_DISTRO=redhat8 molecule create
$ MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-linux-package --destroy never
$ MOLECULE_DISTRO=redhat8 molecule login
$ molecule destroy
```

### converge/test on role 'bootstrap-linux-docker'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_DISTRO=redhat8 molecule create
$ MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-linux-docker --destroy never
$ MOLECULE_DISTRO=redhat8 molecule login
$ MOLECULE_DISTRO=redhat8 molecule destroy -s bootstrap-linux-docker
$ MOLECULE_DISTRO=centos7 molecule converge --destroy never
$ MOLECULE_DISTRO=centos7 molecule login
$ molecule destroy --all
$ MOLECULE_DISTRO=centos8 --debug converge
$ molecule destroy --all
$ MOLECULE_DISTRO=ubuntu2004 converge
$ molecule destroy --all
$ MOLECULE_DISTRO=ubuntu2204 --debug converge

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
MOLECULE_DISTRO=centos7 molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=centos7 molecule --debug create -s bootstrap-linux
MOLECULE_DISTRO=centos7 molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=centos7 molecule --debug test -s bootstrap-linux
MOLECULE_DISTRO=centos7 molecule --debug test -s bootstrap-linux --destroy never
MOLECULE_DISTRO=centos7 molecule --debug verify -s bootstrap-linux
MOLECULE_DISTRO=centos7 molecule --debug verify -s bootstrap-linux --destroy never
MOLECULE_DISTRO=centos8 molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=centos8 molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=centos8 molecule --debug test -s bootstrap-linux --destroy never
MOLECULE_DISTRO=centos8 molecule destroy --all
MOLECULE_DISTRO=debian9 MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=debian9 MOLECULE_DOCKER_COMMAND=/usr/sbin/init molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=debian9 molecule --debug -s bootstrap-linux destroy --all
MOLECULE_DISTRO=debian9 molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=debian9 molecule --debug destroy --all -s bootstrap-linux
MOLECULE_DISTRO=debian9 molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=debian9 molecule --debug destroy -s bootstrap-linux destroy
MOLECULE_IMAGE=lj020326/centos8-systemd-python molecule --debug create -s bootstrap-linux
MOLECULE_IMAGE=lj020326/centos8-systemd-python molecule --debug create -s bootstrap-linux --destroy never
MOLECULE_IMAGE=media.johnson.int:5000/centos8-systemd-python molecule --debug create -s bootstrap-linux --destroy never
MOLECULE_IMAGE_NAMESPACE=media.johnson.int:5000 MOLECULE_DISTRO=centos8 molecule --debug create -s bootstrap-linux --destroy never
MOLECULE_DISTRO=redhat8 MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=redhat8 molecule --debug -s bootstrap-linux converge
MOLECULE_DISTRO=redhat8 molecule --debug converge --all -s bootstrap-linux
MOLECULE_DISTRO=redhat8 molecule --debug converge -s bootstrap-linux
MOLECULE_DISTRO=redhat8 molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=redhat8 molecule --debug converge -s bootstrap-linux-docker --destroy never
MOLECULE_DISTRO=redhat8 molecule --debug create -s bootstrap-linux
MOLECULE_DISTRO=redhat8 molecule --debug destroy --all
MOLECULE_DISTRO=redhat8 molecule --debug destroy --all -s bootstrap-linux
MOLECULE_DISTRO=redhat8 molecule --debug destroy --all -s bootstrap-linux-docker
MOLECULE_DISTRO=redhat8 molecule --debug destroy -s bootstrap-linux
MOLECULE_DISTRO=redhat8 molecule --debug destroy -s bootstrap-linux-docker
MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-linux --destroy never
MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-linux-docker --destroy never
MOLECULE_DISTRO=redhat8 molecule create
MOLECULE_DISTRO=redhat8 molecule destroy
MOLECULE_DISTRO=redhat8 molecule destroy --all
MOLECULE_DISTRO=redhat8 molecule login
MOLECULE_DISTRO=ubuntu2204 molecule --debug converge -s bootstrap-linux-docker
MOLECULE_DISTRO=ubuntu2204 molecule destroy
MOLECULE_DISTRO=ubuntu2204 molecule destroy --all
MOLECULE_DISTRO=centos8 molecule --debug destroy -s bootstrap-linux
MOLECULE_IMAGE_NAMESPACE=lj020326 MOLECULE_DISTRO=centos8 molecule --debug create -s bootstrap-linux
MOLECULE_IMAGE_NAMESPACE=lj020326 MOLECULE_DISTRO=centos8 molecule --debug test -s bootstrap-linux --destroy never
ansible-galaxy collection install -vvv -fr collections/requirements.molecule.yml 
cat requirements.molecule.txt 
echo $MOLECULE_DISTRO
echo $MOLECULE_IMAGE
echo $MOLECULE_IMAGE_NAMESPACE
molecule --version
molecule destroy
molecule destroy --all
molecule/docker-image-sync.sh centos7-systemd-python
molecule/docker-image-sync.sh centos8-systemd-python
molecule/docker-image-sync.sh media.johnson.int:5000/centos8-systemd-python
molecule/docker-image-sync.sh centos8-systemd-python hub.docker.com
molecule/docker-image-sync.sh centos8-systemd-python registry.hub.docker.com
molecule/docker-image-sync.sh lj020326/centos8-systemd-python registry.hub.docker.com
molecule/docker-image-sync.sh redhat8-systemd-python
```
