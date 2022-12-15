
# Molecule testing with ansible-datacenter 


## Run molecule tests

```shell
$ PROJECT_DIR="$( git rev-parse --show-toplevel )"
$ cd ${COLLECTION_DIR}
$ export MOLECULE_DISTRO=redhat7-systemd-python
$ molecule --debug test --destroy never
$ molecule login
$ molecule --debug test -s bootstrap-linux-package
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-package --destroy never
$ MOLECULE_DISTRO=redhat8-systemd-python molecule login
$ molecule destroy
$ MOLECULE_DISTRO=centos7-systemd-python molecule converge --destroy never
$ MOLECULE_DISTRO=centos7-systemd-python molecule login
$ molecule destroy
$ MOLECULE_DISTRO=centos8-systemd-python --debug converge
$ molecule destroy
$ MOLECULE_DISTRO=ubuntu2004-systemd-python converge
$ molecule destroy
$ MOLECULE_DISTRO=ubuntu2204-systemd-python --debug converge

```

```shell
$ tests/molecule_exec.sh centos7 converge
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge
$ molecule destroy

```

To log into container

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 create
$ tests/molecule_exec.sh redhat7 login
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
