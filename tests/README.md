
# Tests

## Run molecule tests

```shell
$ PROJECT_DIR="$( git rev-parse --show-toplevel )"
$ cd ${COLLECTION_DIR}
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge

```
