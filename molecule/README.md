
# Tests

## Run molecule tests

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
## do this will reset any prior instance state(s) such that converge should create new instance
## ref: https://github.com/ansible-community/molecule/issues/3094#issuecomment-1157865556
$ molecule destroy --all
$ export MOLECULE_DISTRO=redhat7-systemd-python
$ molecule create
$ molecule login
$ molecule --debug test -s bootstrap-linux-package
$ MOLECULE_DISTRO=redhat8-systemd-python molecule destroy --all
$ MOLECULE_DISTRO=redhat8-systemd-python molecule converge -s bootstrap-linux-package
$ MOLECULE_DISTRO=redhat8-systemd-python molecule destroy --all
$ MOLECULE_DISTRO=redhat8-systemd-python molecule test -s bootstrap-linux-package --destroy never
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule create
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-package --destroy never
$ MOLECULE_DISTRO=redhat8-systemd-python molecule login
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule create
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-docker --destroy never
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
