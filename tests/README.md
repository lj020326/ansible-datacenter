
Run molecule tests

```shell
$ PROJECT_DIR="$( git rev-parse --show-toplevel )"
$ cd ${COLLECTION_DIR}
$ molecule destroy
$ tests/molecule_exec.sh converge centos7
$ molecule destroy
$ tests/molecule_exec.sh converge centos8
$ molecule destroy
$ tests/molecule_exec.sh converge ubuntu2004
$ molecule destroy
$ tests/molecule_exec.sh converge ubuntu2204

```
