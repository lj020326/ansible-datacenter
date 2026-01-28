
# Tests

## Prepare molecule env

## Run molecule tests

The molecule tests below use the [python enabled docker systemd images defined here](https://github.com/lj020326/systemd-python-dockerfiles/tree/main/systemd).

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ pip install -r requirements.molecule.txt
$ ansible-galaxy install --upgrade -r collections/requirements.molecule.txt
```

## To sync the latest image version

```shell
$ docker-image-sync.sh redhat9-systemd-python
```

## Create molecule container

```shell
## optional: set registry environment variable if using local/private registry
$ export MOLECULE_IMAGE_REGISTRY=registry.example.int:5000
$ #export MOLECULE_IMAGE_REGISTRY=media.johnson.int:5000
## if internal OR non-public registry requiring login:
$ docker login -u "${DOCKER_REGISTRY_USERNAME}" -p "${DOCKER_REGISTRY_PASSWORD}" "${DOCKER_REGISTRY_INTERNAL}"
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug create -s bootstrap_linux
```

### Handling 'Unable to contact the Docker daemon' error

If you get the 'Unable to contact the Docker daemon' result when running molecule as follows:
```shell
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug converge -s bootstrap_linux
...
INFO     Confidence checks: 'docker'
CRITICAL Unable to contact the Docker daemon. Please refer to https://docs.docker.com/config/daemon/ for managing the daemon
$ 
$ telnet localhost 2375
Trying ::1...
Connection failed: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
^]
telnet> q
Connection closed.

```

Check the docker version / info
```shell
$ docker version
Client:
 Version:           23.0.6
 API version:       1.42
 Go version:        go1.19.9
 Git commit:        ef23cbc
 Built:             Fri May  5 21:14:58 2023
 OS/Arch:           darwin/amd64
 Context:           default
error during connect: Get "http://docker:2375/v1.24/version": dial tcp: lookup docker: no such host
$ docker info
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.14.1-desktop.1
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.27.1-desktop.1
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-compose
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.0.32
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-debug
  dev: Docker Dev Environments (Docker Inc.)
    Version:  v0.1.2
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-dev
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.24
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-extension
  feedback: Provide feedback, right in your terminal! (Docker Inc.)
    Version:  v1.0.5
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-feedback
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.2.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-init
  sbom: View the packaged-based Software Bill Of Materials (SBOM) for an image (Anchore Inc.)
    Version:  0.6.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-sbom
  scout: Docker Scout (Docker Inc.)
    Version:  v1.9.3
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-scout

Server:
ERROR: error during connect: Get "http://docker:2375/v1.24/info": dial tcp: lookup docker: no such host
errors pretty printing info

```

The results above indicate a communications issue most likely affected by the `DOCKER_HOST` environment variable.
So we check the value for the `DOCKER_HOST` environment variable:
```shell
$ echo $DOCKER_HOST
tcp://docker:2375
```

So unset the variable and retry:
```shell
$ unset DOCKER_HOST
$ echo $DOCKER_HOST
$ docker version
Client:
 Version:           23.0.6
 API version:       1.42
 Go version:        go1.19.9
 Git commit:        ef23cbc
 Built:             Fri May  5 21:14:58 2023
 OS/Arch:           darwin/amd64
 Context:           desktop-linux

Server: Docker Desktop 4.31.0 (153195)
 Engine:
  Version:          26.1.4
  API version:      1.45 (minimum version 1.24)
  Go version:       go1.21.11
  Git commit:       de5c9cf
  Built:            Wed Jun  5 11:29:22 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.33
  GitCommit:        d2d58213f83a351ca8f528a95fbd145f5654e957
 runc:
  Version:          1.1.12
  GitCommit:        v1.1.12-0-g51d5e94
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
$ 
```

```shell
$ molecule --debug test
```

Conversely the environment variable may require setup per: 
https://stackoverflow.com/questions/70199313/how-to-use-docker-host-error-during-connect 

### Handling 'SyntaxError: future feature annotations is not defined' error

Ansible core 2.16 is slated to be something of an 'LTS' release, [according to one of the core maintainers](https://github.com/ansible/ansible/issues/83357#issuecomment-2148280535)—so if you lock into that version of Ansible core anywhere you run code against RHEL 8 servers, you should be good to go:

```shell
$ pip3 install 'ansible-core<2.17'
```

ref: https://www.jeffgeerling.com/blog/2024/newer-versions-ansible-dont-work-rhel-8


## Converge molecule container

```shell
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug converge -s bootstrap_linux
```

## Test molecule container

```shell
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python \
  molecule --debug test -s bootstrap_linux --destroy never
```

```shell
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_linux --destroy never
```

## Run molecule test

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
## do this will reset any prior instance state(s) such that converge should create new instance
## ref: https://github.com/ansible-community/molecule/issues/3094#issuecomment-1157865556
$ molecule destroy --all
$ export MOLECULE_IMAGE_LABEL=redhat9-systemd-python
$ molecule create
$ molecule login
$ molecule --debug test -s bootstrap_linux_package
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule test -s bootstrap_linux --destroy never
## after several iterations - then finally remove it
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule destroy -s bootstrap_linux
```

## Typical role development cycle using molecule

```shell
## make sure no container exists first using `destroy` action
$ tests/molecule_exec.sh centos9 destroy -s bootstrap_webmin
## develop role and apply/test on new container using `test` assuming tests have already been defined; otherwise, use `converge` action
$ tests/molecule_exec.sh centos9 converge -s bootstrap_webmin
## if issue occurs with role such that in-container/manual testing needs to be performed/done, log/bash into the container using `login` action
$ tests/molecule_exec.sh centos9 login -s bootstrap_webmin
## assuming in-container/manual testing resolved the issue and the role has been updated with the necessary changes, 
## now re-apply the `converge` using the role on the existing container to validate that the changes work as expected (assume idempotent role)
$ tests/molecule_exec.sh centos9 converge -s bootstrap_webmin
## if successful, destroy and test again using clean container to verify that the role works from image start 
$ tests/molecule_exec.sh centos9 destroy -s bootstrap_webmin
$ tests/molecule_exec.sh centos9 converge -s bootstrap_webmin
```

### converge/test on role 'bootstrap-linux'

```shell
$ docker-image-sync.sh centos9-systemd-python
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule converge -s bootstrap_linux | tee -a save/molecule.log
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule converge -s bootstrap_linux_package | tee -a save/molecule.log
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule destroy -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule test -s bootstrap_linux_package --destroy never | tee -a molecule.log
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule test -s bootstrap_docker --destroy never | tee -a molecule.log
$ molecule destroy
```

### converge/test on role 'bootstrap-linux-package'

```shell
$ docker-image-sync.sh ubuntu2404-systemd-python
$ MOLECULE_IMAGE_LABEL=ubuntu2404-systemd-python molecule create
$ MOLECULE_IMAGE_LABEL=ubuntu2404-systemd-python molecule converge -s bootstrap_linux_package
$ MOLECULE_IMAGE_LABEL=ubuntu2404-systemd-python molecule --debug test -s bootstrap_linux_package --destroy never
$ MOLECULE_IMAGE_LABEL=ubuntu2404-systemd-python molecule login
$ molecule destroy
```

### converge/test on role 'bootstrap-docker'

```shell
$ docker-image-sync.sh centos9-systemd-python
$ docker-image-sync.sh redhat9-systemd-python
$ docker-image-sync.sh redhat9-systemd-python
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule create
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule login
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule destroy -s bootstrap_docker
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule converge --destroy never
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule login
$ molecule destroy --all
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python --debug converge
$ molecule destroy --all
$ MOLECULE_IMAGE_LABEL=ubuntu2004-systemd-python molecule converge -s bootstrap_linux | tee -a molecule.log
$ molecule destroy --all
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule test -s bootstrap_linux_package | tee -a ~/cli.run-molecule.log
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule destroy -s bootstrap_linux_package

```

To log/bash into container

```shell
$ molecule create
$ molecule login
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule login
$ tests/molecule_exec.sh centos9 login -s bootstrap_webmin
```

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 converge
$ tests/molecule_exec.sh redhat7 destroy
## OR 
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python redhat7 destroy
$ 
$ tests/molecule_exec.sh ubuntu2204 converge -s bootstrap_linux
$ tests/molecule_exec.sh ubuntu2204 converge -s bootstrap_pip
$ tests/molecule_exec.sh ubuntu2204 converge -s bootstrap_docker
$ tests/molecule_exec.sh debian8 converge
$ molecule destroy
$ tests/molecule_exec.sh centos9 converge
$ molecule destroy
$ tests/molecule_exec.sh centos9 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge

```

```shell
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug create -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule login -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_linux_package --destroy never
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug verify -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug verify -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule destroy --all
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python MOLECULE_DOCKER_COMMAND=/usr/sbin/init molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python molecule --debug -s bootstrap_linux destroy --all
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python molecule --debug destroy --all -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=debian9-systemd-python molecule --debug destroy -s bootstrap_linux destroy
$ MOLECULE_IMAGE=media.johnson.int:5000/centos9-systemd-python molecule --debug create -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_REGISTRY=media.johnson.int:5000 MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug create -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug -s bootstrap_linux converge
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug converge --all -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug converge -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug create -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug destroy --all
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug destroy --all -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug destroy --all -s bootstrap_docker
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug destroy -s bootstrap_docker
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule create
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule destroy
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule destroy --all
$ MOLECULE_IMAGE_LABEL=redhat9-systemd-python molecule login
$ MOLECULE_IMAGE_LABEL=ubuntu2204-systemd-python molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE_LABEL=ubuntu2204-systemd-python molecule destroy
$ MOLECULE_IMAGE_LABEL=ubuntu2204-systemd-python molecule destroy --all
$ MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE_REGISTRY=lj020326 MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug create -s bootstrap_linux
$ MOLECULE_IMAGE_REGISTRY=lj020326 MOLECULE_IMAGE_LABEL=centos9-systemd-python molecule --debug test -s bootstrap_linux --destroy never
$ ansible-galaxy collection install -vvv -fr collections/requirements.molecule.yml 
$ cat requirements.molecule.txt 
$ echo $MOLECULE_IMAGE_LABEL
$ echo $MOLECULE_IMAGE_REGISTRY
$ molecule --version
$ molecule destroy
$ molecule destroy --all
$ molecule/docker-image-sync.sh centos9-systemd-python
$ molecule/docker-image-sync.sh centos9-systemd-python
$ molecule/docker-image-sync.sh media.johnson.int:5000/centos9-systemd-python
$ molecule/docker-image-sync.sh centos9-systemd-python hub.docker.com
$ molecule/docker-image-sync.sh centos9-systemd-python registry.hub.docker.com
$ molecule/docker-image-sync.sh lj020326/centos9-systemd-python registry.hub.docker.com
$ molecule/docker-image-sync.sh redhat9-systemd-python
```
