
# Tests

Testing of the linux OS bootstrap playbooks is performed by molecule with platforms defined in ['molecule.yml'](molecule/default/molecule.yml) and the ['converge.yml'](molecule/default/converge.yml).

Molecule scenarios have been set up to include the overall platform provisioning/orchestration role converge playbook for [bootstrap_linux](./molecule/bootstrap_linux/converge.yml) as well as multiple key roles invoked within the `bootstrap_linux` orchestration role to allow/enable isolated/granular testing when and as needed.

The molecule test pipeline is set up in the [github workflows](.github/workflows) and the molecule converge test results for each platform can be viewed on [github actions results page](https://github.com/lj020326/ansible-datacenter/actions).

---

## Molecule Test Scripts Comparison

| Script                 | Purpose                                                                                                         | Status          |
|:-----------------------|:----------------------------------------------------------------------------------------------------------------|:----------------|
| `run-molecule-test.sh` | **Primary Entrypoint.** Supports dynamic scenario discovery, image mapping (shortnames), and sorted help menus. | **Recommended** |
| `molecule_tests.sh`    | Batch runner. Iterates through a hardcoded list of images to run a scenario against multiple platforms.         | Legacy / Batch  |
| `molecule_exec.sh`     | Minimal wrapper. Directly passes commands to molecule with image environment variables.                         | Legacy / Manual |

## Run Molecule Tests

The recommended way to run tests is using the `run-molecule-test.sh` script. It automatically maps short OS names (e.g., `ubuntu24`) to the correct systemd-enabled Docker images and validates that the requested scenario exists.

The systemd-python enabled docker images used by these tests can be found on [DockerHub](https://www.google.com/search?q=https://hub.docker.com/repositories/lj020326%3Fsearch%3Dsystemd).  The image definitions for the systemd-python enabled docker platform containers used in the molecule tests can be found on [github](https://github.com/lj020326/systemd-python-dockerfiles).

### Examples using `run-molecule-test.sh`

**Basic Usage (Default Scenario):**
```bash
$ run-molecule-test.sh  ## runs with default action `test` and default scenario `bootstrap_linux_package`
```

#### Run a specific scenario with a specific image:

```bash
# Usage: ./run-molecule-test.sh -i <image_shortname> <scenario_name>
./run-molecule-test.sh -i ubuntu24 bootstrap_linux_package
```

#### Run with Debug logging:

```bash
./run-molecule-test.sh -L DEBUG bootstrap_pip
```

#### List all valid scenarios and images:

```bash
$ run-molecule-test.sh -h
Usage: run-molecule-test.sh [options] [MOLECULE_TEST_SCENARIO (default: bootstrap_linux_package)]

  Options:
       -L [ERROR|WARN|INFO|TRACE|DEBUG] : log level (default: INFO)
       -a : MOLECULE_COMMAND (create|login|converge|test|destroy|...)
       -i : MOLECULE_IMAGE_SHORT (centos10|centos9|debian10|debian11|debian12|ubuntu22|ubuntu24|ubuntu26)
       -d : run molecule with '--debug' flag
       -l : list test cases
       -v : show version
       -h : help

  Available Scenarios:
       - bootstrap_docker
       - bootstrap_java
       - bootstrap_linux
       - bootstrap_linux_core
       - bootstrap_linux_firewalld
       - bootstrap_linux_package
       - bootstrap_ntp
       - bootstrap_pip
       - bootstrap_postfix
       - bootstrap_sshd
       - bootstrap_systemd_tmp_mount
       - bootstrap_webmin
       - default

  Examples:
       run-molecule-test.sh 
       run-molecule-test.sh -l
       run-molecule-test.sh bootstrap_linux_package
       run-molecule-test.sh -i ubuntu26 bootstrap_ntp
       run-molecule-test.sh -a create -i debian12
       run-molecule-test.sh -a login -i centos10
       run-molecule-test.sh -d -a converge -i centos10 bootstrap_sshd
       run-molecule-test.sh -L DEBUG bootstrap_pip
       run-molecule-test.sh -L DEBUG
       run-molecule-test.sh -v
```

### Legacy Execution (Manual)

If you need to bypass the helper script or run manual molecule actions (like login or converge) using the older molecule_exec.sh wrapper:

```bash
# Format: ./molecule_exec.sh <full_image_name> <molecule_action>
./molecule_exec.sh lj020326/systemd-python-centos:9 login
./molecule_exec.sh lj020326/systemd-python-ubuntu:26.04 converge -s bootstrap_docker
```

### Environment Variables

The molecule tests utilize the following environment variables (handled automatically by `run-molecule-test.sh`):

* `MOLECULE_IMAGE`: The full name of the Docker image (e.g., `lj020326/systemd-python-ubuntu:24.04`).
* `MOLECULE_IMAGE_REGISTRY`: (Optional) Custom registry prefix if not using DockerHub.

---

## Prepare molecule env

The molecule tests below use the [python enabled docker systemd images defined here](https://github.com/lj020326/systemd-python-dockerfiles/tree/main/systemd).

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ pip install -r requirements.molecule.txt
$ ansible-galaxy install --upgrade -r collections/requirements.molecule.txt
```

---

## Typical role development cycle using molecule

Note the `run-molecule-test.sh` supports the `-a` option for specifying molecule actions.

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
## 1. Ensure no container exists first using `destroy` action
$ ./run-molecule-test.sh -i ubuntu26 -a destroy bootstrap_webmin

## 2. Develop role and apply to a new container using `converge`
$ ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_webmin

## 3. If manual testing is needed, log into the running container
$ ./run-molecule-test.sh -i ubuntu26 -a login bootstrap_webmin

## 4. After fixing code, re-apply `converge` to the existing container to validate
$ ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_webmin

## 5. Once successful, run a full `test` sequence (destroy/create/converge/idempotence/verify/destroy)
$ ./run-molecule-test.sh -i ubuntu26 -a test bootstrap_webmin
```

## Examples by Role Scenario

The following examples demonstrate testing across different OS distributions using shortnames.

### Role: bootstrap_linux

```shell
# Synchronize local images if needed
$ ./molecule/docker-image-sync.sh systemd-python-centos:9
# Run converge on CentOS 9
$ ./run-molecule-test.sh -i centos9 -a converge bootstrap_linux
# Run a full test on RedHat 9 (logs are automatically saved to save/ directory)
$ ./run-molecule-test.sh -i redhat9 -a test bootstrap_linux
```

### Role: bootstrap_linux_package

```shell
# Test on Ubuntu 24.04
$ ./run-molecule-test.sh -i ubuntu24 -a test bootstrap_linux_package

# Debug a specific failure on Debian 12 without destroying the container on finish
# (Note: Use -L DEBUG for script verbosity)
$ ./run-molecule-test.sh -L DEBUG -i debian12 -a converge bootstrap_linux_package
```

### Role: bootstrap_docker

```shell
# Initialize and log in for manual inspection
$./run-molecule-test.sh -i redhat9 -a create bootstrap_docker$ ./run-molecule-test.sh -i redhat9 -a login bootstrap_docker

# Cleanup
$ ./run-molecule-test.sh -i redhat9 -a destroy bootstrap_docker
```

### Quick Commands Reference

| Action             | Command                                                  |
|--------------------|----------------------------------------------------------|
| Log into container | ./run-molecule-test.sh -i <image> -a login <scenario>    |
| Reset environment  | ./run-molecule-test.sh -i <image> -a destroy <scenario>  |
| Run specific task  | ./run-molecule-test.sh -i <image> -a converge <scenario> |
| Full Validation    | ./run-molecule-test.sh -i <image> -a test <scenario>     |

### More examples

```shell
## make sure no container exists first using `destroy` action
$ ./run-molecule-test.sh -i centos9 -a destroy bootstrap_webmin
## develop role and apply/test on new container using `test` assuming tests have already been defined; otherwise, use `converge` action
$ ./run-molecule-test.sh -i centos9 -a converge bootstrap_webmin
## if issue occurs with role such that in-container/manual testing needs to be performed/done, log/bash into the container using `login` action
$ ./run-molecule-test.sh -i centos9 -a login bootstrap_webmin
## assuming in-container/manual testing resolved the issue and the role has been updated with the necessary changes, 
## now re-apply the `converge` using the role on the existing container to validate that the changes work as expected (assume idempotent role)
$ ./run-molecule-test.sh -i centos9 -a converge bootstrap_webmin
## if successful, destroy and test again using clean container to verify that the role works from image start 
$ ./run-molecule-test.sh -i centos9 -a destroy bootstrap_webmin
$ ./run-molecule-test.sh -i centos9 -a converge bootstrap_webmin
```

To log into container

```shell
$ ./run-molecule-test.sh -i centos9 -a login bootstrap_webmin
```

```shell
$ molecule destroy
$ ./run-molecule-test.sh -i centos10 -a converge
$ ./run-molecule-test.sh -i centos10 -a destroy
## OR 
$ MOLECULE_IMAGE=systemd-python-centos:10 molecule destroy
$ 
$ ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_linux
$ ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_pip
$ ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_sshd
$ ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_docker
$ ./run-molecule-test.sh -i debian8 -a converge
$ ./run-molecule-test.sh -i centos9 -a converge
## with --debug enabled
$ ./run-molecule-test.sh -d -i ubuntu26 -a create
$ ./run-molecule-test.sh -i ubuntu24 -a login
## with increased ansible provisioning verbosity
$ ANSIBLE_VERBOSITY=3 ./run-molecule-test.sh -i ubuntu26 -a converge bootstrap_pip
```

## Molecule using manual method

### Create molecule container

```shell
## optional: set registry environment variable if using local/private registry
$ export MOLECULE_IMAGE_REGISTRY=registry.example.int:5000
$ #export MOLECULE_IMAGE_REGISTRY=media.johnson.int:5000
## if internal OR non-public registry requiring login:
$ docker login -u "${DOCKER_REGISTRY_USERNAME}" -p "${DOCKER_REGISTRY_PASSWORD}" "${DOCKER_REGISTRY_INTERNAL}"
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug create -s bootstrap_linux
```

Testing of the linux OS bootstrap playbooks is performed by molecule with platforms defined in ['molecule.yml'](molecule/default/molecule.yml) and the ['converge.yml'](molecule/default/converge.yml).

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

### Converge molecule container

```shell
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug converge -s bootstrap_linux
```

### Test molecule container

```shell
$ MOLECULE_IMAGE=systemd-python-centos:9 \
  molecule --debug test -s bootstrap_linux --destroy never
```

```shell
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule --debug test -s bootstrap_linux --destroy never
```

### To run molecule with increased ansible logging

```shell
$ ANSIBLE_VERBOSITY=3 MOLECULE_IMAGE=systemd-python-ubuntu:26.04 molecule prepare -s bootstrap_ntp
```

---

### converge/test on role 'bootstrap-linux'

```shell
$ docker-image-sync.sh systemd-python-centos:9
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
$ docker-image-sync.sh systemd-python-ubuntu:24.04
$ MOLECULE_IMAGE=systemd-python-ubuntu:24.04 molecule create
$ MOLECULE_IMAGE=systemd-python-ubuntu:24.04 molecule converge -s bootstrap_linux_package
$ MOLECULE_IMAGE=systemd-python-ubuntu:24.04 molecule --debug test -s bootstrap_linux_package --destroy never
$ MOLECULE_IMAGE=systemd-python-ubuntu:24.04 molecule login
$ molecule destroy
```

### converge/test on role 'bootstrap-docker'

```shell
$ docker-image-sync.sh systemd-python-centos:9
$ docker-image-sync.sh systemd-python-centos:10
$ docker-image-sync.sh systemd-python-ubuntu:26.04
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule create
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule --debug test -s bootstrap_docker --destroy never
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule login
$ MOLECULE_IMAGE=systemd-python-redhat:9 molecule destroy -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule converge --destroy never
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule login
$ molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-centos:9 --debug converge
$ molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-ubuntu:26.04 molecule converge -s bootstrap_linux | tee -a molecule.log
$ molecule destroy --all
$ MOLECULE_IMAGE=systemd-python-centos:10 molecule test -s bootstrap_pip | tee -a molecule.log
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule test -s bootstrap_linux_package | tee -a ~/cli.run-molecule.log
$ MOLECULE_IMAGE=systemd-python-centos:9 molecule destroy -s bootstrap_linux_package
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
$ MOLECULE_IMAGE=systemd-python-ubuntu:26.04 molecule --debug converge -s bootstrap_docker
$ MOLECULE_IMAGE=systemd-python-ubuntu:26.04 molecule destroy
$ MOLECULE_IMAGE=systemd-python-ubuntu:26.04 molecule destroy --all
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

---

## Sync the latest image version

```shell
$ docker-image-sync.sh systemd-python-redhat:9
```

---

## Handling 'Unable to contact the Docker daemon' error

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

Conversely, the environment variable may require setup per: 
https://stackoverflow.com/questions/70199313/how-to-use-docker-host-error-during-connect 
