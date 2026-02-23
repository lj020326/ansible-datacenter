
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
$ docker-image-sync.sh systemd-python-redhat:9
```

## Create molecule container

```shell
## optional: set registry environment variable if using local/private registry
$ export MOLECULE_IMAGE_REGISTRY=registry.example.int:5000
$ #export MOLECULE_IMAGE_REGISTRY=media.johnson.int:5000
## if internal OR non-public registry requiring login:
$ docker login -u "${DOCKER_REGISTRY_USERNAME}" -p "${DOCKER_REGISTRY_PASSWORD}" "${DOCKER_REGISTRY_INTERNAL}"
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug create -s bootstrap_linux
```

### Handling 'Unable to contact the Docker daemon' error

If you get the 'Unable to contact the Docker daemon' result when running molecule as follows:
```shell
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug converge -s bootstrap_linux
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
 Version:           28.5.1
 API version:       1.51
 Go version:        go1.24.8
 Git commit:        e180ab8
 Built:             Wed Oct  8 12:16:17 2025
 OS/Arch:           darwin/amd64
 Context:           desktop-linux

error during connect: Get "http://docker:2375/v1.24/version": dial tcp: lookup docker: no such host
$ docker info
Client:
 Version:    28.5.1
 Context:    desktop-linux
 Debug Mode: false
 Plugins:
  ai: Docker AI Agent - Ask Gordon (Docker Inc.)
    Version:  v1.9.11
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-ai
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.29.1-desktop.1
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-buildx
  cloud: Docker Cloud (Docker Inc.)
    Version:  v0.4.39
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-cloud
  compose: Docker Compose (Docker Inc.)
    Version:  v2.40.0-desktop.1
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-compose
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.0.44
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-debug
  desktop: Docker Desktop commands (Docker Inc.)
    Version:  v0.2.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-desktop
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.31
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-extension
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.4.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-init
  mcp: Docker MCP Plugin (Docker Inc.)
    Version:  v0.23.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-mcp
  sbom: View the packaged-based Software Bill Of Materials (SBOM) for an image (Anchore Inc.)
    Version:  0.6.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-sbom
  scout: Docker Scout (Docker Inc.)
    Version:  v1.18.3
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
 Version:           28.5.1
 API version:       1.51
 Go version:        go1.24.8
 Git commit:        e180ab8
 Built:             Wed Oct  8 12:16:17 2025
 OS/Arch:           darwin/amd64
 Context:           desktop-linux

Server: Docker Desktop 4.48.0 (207573)
 Engine:
  Version:          28.5.1
  API version:      1.51 (minimum version 1.24)
  Go version:       go1.24.8
  Git commit:       f8215cc
  Built:            Wed Oct  8 12:17:24 2025
  OS/Arch:          linux/amd64
  Experimental:     true
 containerd:
  Version:          1.7.27
  GitCommit:        05044ec0a9a75232cad458027ca83437aae3f4da
 runc:
  Version:          1.2.5
  GitCommit:        v1.2.5-0-g59923ef
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
ljohnson@lees-mbp:[ansible-datacenter](main)$ 
ljohnson@lees-mbp:[ansible-datacenter](main)$ docker info
Client:
 Version:    28.5.1
 Context:    desktop-linux
 Debug Mode: false
 Plugins:
  ai: Docker AI Agent - Ask Gordon (Docker Inc.)
    Version:  v1.9.11
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-ai
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.29.1-desktop.1
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-buildx
  cloud: Docker Cloud (Docker Inc.)
    Version:  v0.4.39
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-cloud
  compose: Docker Compose (Docker Inc.)
    Version:  v2.40.0-desktop.1
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-compose
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.0.44
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-debug
  desktop: Docker Desktop commands (Docker Inc.)
    Version:  v0.2.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-desktop
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.31
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-extension
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.4.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-init
  mcp: Docker MCP Plugin (Docker Inc.)
    Version:  v0.23.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-mcp
  sbom: View the packaged-based Software Bill Of Materials (SBOM) for an image (Anchore Inc.)
    Version:  0.6.0
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-sbom
  scout: Docker Scout (Docker Inc.)
    Version:  v1.18.3
    Path:     /Users/ljohnson/.docker/cli-plugins/docker-scout

Server:
 Containers: 37
  Running: 18
  Paused: 0
  Stopped: 19
 Images: 275
 Server Version: 28.5.1
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Discovered Devices:
  cdi: docker.com/gpu=webgpu
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 05044ec0a9a75232cad458027ca83437aae3f4da
 runc version: v1.2.5-0-g59923ef
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
 Kernel Version: 6.10.14-linuxkit
 Operating System: Docker Desktop
 OSType: linux
 Architecture: x86_64
 CPUs: 12
 Total Memory: 7.655GiB
 Name: docker-desktop
 ID: 13cfc0aa-ef1a-439e-9d32-a267e81473f0
 Docker Root Dir: /var/lib/docker
 Debug Mode: true
  File Descriptors: 142
  Goroutines: 170
  System Time: 2026-02-21T15:42:18.257710734Z
  EventsListeners: 14
 HTTP Proxy: http.docker.internal:3128
 HTTPS Proxy: http.docker.internal:3128
 No Proxy: hubproxy.docker.internal
 Labels:
  com.docker.desktop.address=unix:///Users/ljohnson/Library/Containers/com.docker.docker/Data/docker-cli.sock
 Experimental: true
 Insecure Registries:
  hubproxy.docker.internal:5555
  ::1/128
  127.0.0.0/8
 Registry Mirrors:
  https://media.johnson.int:5000/
  https://admin.dettonville.int:5000/
 Live Restore Enabled: false
$ docker version
Client:
 Version:           28.5.1
 API version:       1.51
 Go version:        go1.24.8
 Git commit:        e180ab8
 Built:             Wed Oct  8 12:16:17 2025
 OS/Arch:           darwin/amd64
 Context:           desktop-linux

Server: Docker Desktop 4.48.0 (207573)
 Engine:
  Version:          28.5.1
  API version:      1.51 (minimum version 1.24)
  Go version:       go1.24.8
  Git commit:       f8215cc
  Built:            Wed Oct  8 12:17:24 2025
  OS/Arch:          linux/amd64
  Experimental:     true
 containerd:
  Version:          1.7.27
  GitCommit:        05044ec0a9a75232cad458027ca83437aae3f4da
 runc:
  Version:          1.2.5
  GitCommit:        v1.2.5-0-g59923ef
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
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug converge -s bootstrap_linux
```

## Test molecule container

```shell
$ MOLECULE_IMAGE=systemd-python-centos:9 \
  molecule --debug test -s bootstrap_linux --destroy never
```

```shell
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux --destroy never
```

## Run molecule test

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
## do this will reset any prior instance state(s) such that converge should create new instance
## ref: https://github.com/ansible-community/molecule/issues/3094#issuecomment-1157865556
$ molecule destroy --all
$ export MOLECULE_IMAGE=systemd-python-redhat:9
$ molecule create
$ molecule login
$ molecule --debug test -s bootstrap_linux_package
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule test -s bootstrap_linux --destroy never
## after several iterations - then finally remove it
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule destroy -s bootstrap_linux
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
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule converge -s bootstrap_linux | tee -a save/molecule.log
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule converge -s bootstrap_linux_package | tee -a save/molecule.log
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule destroy -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule test -s bootstrap_linux_package --destroy never | tee -a molecule.log
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule test -s bootstrap_docker --destroy never | tee -a molecule.log
$ molecule destroy
```

### converge/test on role 'bootstrap-linux-package'

```shell
$ docker-image-sync.sh ubuntu2404-systemd-python
$ MOLECULE_IMAGE=systemd-python-ubuntu:2404 molecule create
$ MOLECULE_IMAGE=systemd-python-ubuntu:2404 molecule converge -s bootstrap_linux_package
$ MOLECULE_IMAGE=systemd-python-ubuntu:2404 molecule --debug test -s bootstrap_linux_package --destroy never
$ MOLECULE_IMAGE=systemd-python-ubuntu:2404 molecule login
$ molecule destroy
```

### converge/test on role 'bootstrap-docker'

```shell
$ docker-image-sync.sh centos9-systemd-python
$ docker-image-sync.sh redhat9-systemd-python
$ docker-image-sync.sh redhat9-systemd-python
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule create
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule login
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule destroy -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule converge --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule login
$ molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-centos:9 --debug converge
$ molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-ubuntu:2004 molecule converge -s bootstrap_linux | tee -a molecule.log
$ molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-centos:10 molecule test -s bootstrap_pip | tee -a molecule.log
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule test -s bootstrap_linux_package | tee -a ~/cli.run-molecule.log
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule destroy -s bootstrap_linux_package
```

To log/bash into container

```shell
$ molecule create
$ molecule login
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule login
$ tests/molecule_exec.sh centos9 login -s bootstrap_webmin
```

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 converge
$ tests/molecule_exec.sh redhat7 destroy
## OR 
$ MOLECULE_IMAGE=systemd-python-centos:9 redhat7 destroy
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
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug create -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule login -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux_package --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug verify -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug verify -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-debian:9 MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-debian:9 MOLECULE_DOCKER_COMMAND=/usr/sbin/init molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-debian:9 molecule --debug -s bootstrap_linux destroy --all
$ MOLECULE_IMAGE=systemd-python-debian:9 molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-debian:9 molecule --debug destroy --all -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-debian:9 molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-debian:9 molecule --debug destroy -s bootstrap_linux destroy
$ MOLECULE_IMAGE=media.johnson.int:5000/systemd-python-centos:9 molecule --debug create -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE_REGISTRY=media.johnson.int:5000 MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug create -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 MOLECULE_DOCKER_COMMAND=/sbin/init molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug -s bootstrap_linux converge
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug converge --all -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug converge -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug converge -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug create -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug destroy --all
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug destroy --all -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug destroy --all -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug destroy -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug test -s bootstrap_linux --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule create
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule destroy
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule login
$ MOLECULE_IMAGE=systemd-python-ubuntu:2204 molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-ubuntu:2204 molecule destroy
$ MOLECULE_IMAGE=systemd-python-ubuntu:2204 molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug destroy -s bootstrap_linux
$ MOLECULE_IMAGE_REGISTRY=lj020326 MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug create -s bootstrap_linux
$ MOLECULE_IMAGE_REGISTRY=lj020326 MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux --destroy never
$ ansible-galaxy collection install -vvv -fr collections/requirements.molecule.yml 
$ cat requirements.molecule.txt 
$ echo $MOLECULE_IMAGE
$ echo $MOLECULE_IMAGE_REGISTRY
$ molecule --version
$ molecule destroy
$ molecule destroy --all
$ molecule/docker-image-sync.sh systemd-python-centos:9
$ molecule/docker-image-sync.sh systemd-python-centos:9
$ molecule/docker-image-sync.sh media.johnson.int:5000/systemd-python-centos:9
$ molecule/docker-image-sync.sh systemd-python-centos:9 hub.docker.com
$ molecule/docker-image-sync.sh systemd-python-centos:9 registry.hub.docker.com
$ molecule/docker-image-sync.sh lj020326/systemd-python-centos:9 registry.hub.docker.com
$ molecule/docker-image-sync.sh systemd-python-redhat:9
```
