
# Install

## Requirements

* Docker Engine
* docker-py
* goss

## Linux Install Details

```shell
$ pip install docker molecule 'molecule-plugins[docker]'
$ curl -fsSL https://goss.rocks/install | GOSS_DST=/usr/local/sbin sh
```

## MacOS Install Details

[Goss doesn't natively run on Mac. Use dgoss to solves this](https://github.com/goss-org/goss/issues/263).

```shell
$ pip install docker molecule 'molecule-plugins[docker]'
$ curl -L https://raw.githubusercontent.com/goss-org/goss/master/extras/dgoss/dgoss -o /usr/local/bin/dgoss && chmod +rx /usr/local/bin/dgoss
```

## References

- https://pypi.org/project/molecule-goss/
- https://github.com/goss-org/goss
- https://github.com/goss-org/goss/tree/master/extras/dgoss
- https://linora-solutions.nl/post/testing_ansible_roles_with_molecule_goss_and_docker/

