
# Tests

## Prepare molecule env

## Run molecule tests

The molecule tests below use the [python enabled docker systemd images defined here](https://github.com/lj020326/systemd-python-dockerfiles/tree/master/systemd).

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ pip install -r requirements.molecule.txt
```

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

```shell
$ MOLECULE_DISTRO=centos8 molecule --debug test -s bootstrap-linux --destroy never
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
$ MOLECULE_DISTRO=redhat8 molecule test -s bootstrap-linux --destroy never
## after several iterations - then finally remove it
$ MOLECULE_DISTRO=redhat8 molecule destroy -s bootstrap-linux
```

## Typical role development cycle using molecule

```shell
## make sure no container exists first using `destroy` action
$ tests/molecule_exec.sh centos8 destroy -s bootstrap-webmin
## develop role and apply/test on new container using `test` assuming tests have already been defined; otherwise, use `converge` action
$ tests/molecule_exec.sh centos8 converge -s bootstrap-webmin
## if issue occurs with role such that in-container/manual testing needs to be performed/done, log/bash into the container using `login` action
$ tests/molecule_exec.sh centos8 login -s bootstrap-webmin
## assuming in-container/manual testing resolved the issue and the role has been updated with the necessary changes, 
## now re-apply the `converge` using the role on the existing container to validate that the changes work as expected (assume idempotent role)
$ tests/molecule_exec.sh centos8 converge -s bootstrap-webmin
## if successful, destroy and test again using clean container to verify that the role works from image start 
$ tests/molecule_exec.sh centos8 destroy -s bootstrap-webmin
$ tests/molecule_exec.sh centos8 converge -s bootstrap-webmin
```

### converge/test on role 'bootstrap-linux'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_DISTRO=redhat8 molecule converge -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule destroy -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule test -s bootstrap-linux --destroy never
$ MOLECULE_DISTRO=redhat8 molecule test -s bootstrap-linux-package --destroy never
$ MOLECULE_DISTRO=redhat8 molecule test -s bootstrap-docker --destroy never
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

### converge/test on role 'bootstrap-docker'

```shell
$ docker-image-sync.sh redhat8-systemd-python
$ MOLECULE_DISTRO=redhat8 molecule create
$ MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-docker --destroy never
$ MOLECULE_DISTRO=redhat8 molecule login
$ MOLECULE_DISTRO=redhat8 molecule destroy -s bootstrap-docker
$ MOLECULE_DISTRO=centos7 molecule converge --destroy never
$ MOLECULE_DISTRO=centos7 molecule login
$ molecule destroy --all
$ MOLECULE_DISTRO=centos8 --debug converge
$ molecule destroy --all
$ MOLECULE_DISTRO=ubuntu2004 converge
$ molecule destroy --all
$ MOLECULE_DISTRO=ubuntu2204 --debug converge

```

To log/bash into container

```shell
$ molecule create
$ molecule login
$ MOLECULE_DISTRO=redhat8 molecule login
$ tests/molecule_exec.sh centos8 login -s bootstrap-webmin
```

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 converge
$ tests/molecule_exec.sh redhat7 destroy
## OR 
$ MOLECULE_DISTRO=centos8 redhat7 destroy
$ 
$ tests/molecule_exec.sh ubuntu2204 converge -s bootstrap-linux
$ tests/molecule_exec.sh ubuntu2204 converge -s bootstrap-pip
$ tests/molecule_exec.sh ubuntu2204 converge -s bootstrap-docker
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
$ MOLECULE_DISTRO=centos7 molecule --debug converge -s bootstrap-linux
$ MOLECULE_DISTRO=centos7 molecule --debug create -s bootstrap-linux
$ MOLECULE_DISTRO=centos7 molecule --debug destroy -s bootstrap-linux
$ MOLECULE_DISTRO=centos7 molecule --debug test -s bootstrap-linux
$ MOLECULE_DISTRO=centos7 molecule --debug test -s bootstrap-linux --destroy never
$ MOLECULE_DISTRO=centos7 molecule --debug test -s bootstrap-linux-package --destroy never
$ MOLECULE_DISTRO=centos7 molecule --debug test -s bootstrap-docker --destroy never
$ MOLECULE_DISTRO=centos7 molecule --debug verify -s bootstrap-linux
$ MOLECULE_DISTRO=centos7 molecule --debug verify -s bootstrap-linux --destroy never
$ MOLECULE_DISTRO=centos8 molecule --debug converge -s bootstrap-docker
$ MOLECULE_DISTRO=centos8 molecule --debug destroy -s bootstrap-linux
$ MOLECULE_DISTRO=centos8 molecule --debug test -s bootstrap-linux --destroy never
$ MOLECULE_DISTRO=centos8 molecule destroy --all
$ MOLECULE_DISTRO=debian9 MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap-linux
$ MOLECULE_DISTRO=debian9 MOLECULE_DOCKER_COMMAND=/usr/sbin/init molecule --debug converge -s bootstrap-linux
$ MOLECULE_DISTRO=debian9 molecule --debug -s bootstrap-linux destroy --all
$ MOLECULE_DISTRO=debian9 molecule --debug converge -s bootstrap-linux
$ MOLECULE_DISTRO=debian9 molecule --debug destroy --all -s bootstrap-linux
$ MOLECULE_DISTRO=debian9 molecule --debug destroy -s bootstrap-linux
$ MOLECULE_DISTRO=debian9 molecule --debug destroy -s bootstrap-linux destroy
$ MOLECULE_IMAGE=lj020326/centos8-systemd-python molecule --debug create -s bootstrap-linux
$ MOLECULE_IMAGE=lj020326/centos8-systemd-python molecule --debug create -s bootstrap-linux --destroy never
$ MOLECULE_IMAGE=media.johnson.int:5000/centos8-systemd-python molecule --debug create -s bootstrap-linux --destroy never
$ MOLECULE_IMAGE_NAMESPACE=media.johnson.int:5000 MOLECULE_DISTRO=centos8 molecule --debug create -s bootstrap-linux --destroy never
$ MOLECULE_DISTRO=redhat8 MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule --debug -s bootstrap-linux converge
$ MOLECULE_DISTRO=redhat8 molecule --debug converge --all -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule --debug converge -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule --debug converge -s bootstrap-docker
$ MOLECULE_DISTRO=redhat8 molecule --debug converge -s bootstrap-docker --destroy never
$ MOLECULE_DISTRO=redhat8 molecule --debug create -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule --debug destroy --all
$ MOLECULE_DISTRO=redhat8 molecule --debug destroy --all -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule --debug destroy --all -s bootstrap-docker
$ MOLECULE_DISTRO=redhat8 molecule --debug destroy -s bootstrap-linux
$ MOLECULE_DISTRO=redhat8 molecule --debug destroy -s bootstrap-docker
$ MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-linux --destroy never
$ MOLECULE_DISTRO=redhat8 molecule --debug test -s bootstrap-docker --destroy never
$ MOLECULE_DISTRO=redhat8 molecule create
$ MOLECULE_DISTRO=redhat8 molecule destroy
$ MOLECULE_DISTRO=redhat8 molecule destroy --all
$ MOLECULE_DISTRO=redhat8 molecule login
$ MOLECULE_DISTRO=ubuntu2204 molecule --debug converge -s bootstrap-docker
$ MOLECULE_DISTRO=ubuntu2204 molecule destroy
$ MOLECULE_DISTRO=ubuntu2204 molecule destroy --all
$ MOLECULE_DISTRO=centos8 molecule --debug destroy -s bootstrap-linux
$ MOLECULE_IMAGE_NAMESPACE=lj020326 MOLECULE_DISTRO=centos8 molecule --debug create -s bootstrap-linux
$ MOLECULE_IMAGE_NAMESPACE=lj020326 MOLECULE_DISTRO=centos8 molecule --debug test -s bootstrap-linux --destroy never
$ ansible-galaxy collection install -vvv -fr collections/requirements.molecule.yml 
$ cat requirements.molecule.txt 
$ echo $MOLECULE_DISTRO
$ echo $MOLECULE_IMAGE_NAMESPACE
$ molecule --version
$ molecule destroy
$ molecule destroy --all
$ molecule/docker-image-sync.sh centos7-systemd-python
$ molecule/docker-image-sync.sh centos8-systemd-python
$ molecule/docker-image-sync.sh media.johnson.int:5000/centos8-systemd-python
$ molecule/docker-image-sync.sh centos8-systemd-python hub.docker.com
$ molecule/docker-image-sync.sh centos8-systemd-python registry.hub.docker.com
$ molecule/docker-image-sync.sh lj020326/centos8-systemd-python registry.hub.docker.com
$ molecule/docker-image-sync.sh redhat8-systemd-python
```
