![Logo](https://raw.githubusercontent.com/idealista/zookeeper_role/master/logo.gif)

# Apache ZooKeeper Ansible role 

[![Build Status](https://travis-ci.org/idealista/zookeeper_role.png)](https://travis-ci.org/idealista/zookeeper_role)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-idealista.zookeeper__role-B62682.svg)](https://galaxy.ansible.com/idealista/zookeeper_role)
[![Docker Hub pulls](https://img.shields.io/docker/pulls/idealista/zookeeper.svg)](https://hub.docker.com/r/idealista/zookeeper/)

This Ansible role installs an Apache ZooKeeper service in a Debian environment.

- [Getting Started](#getting-started)
	- [Prerequisities](#prerequisities)
	- [Installing](#installing)
- [Usage](#usage)
- [Testing](#testing)
- [Built With](#built-with)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)
- [Contributing](#contributing)

## Getting Started

These instructions will get you a copy of the role for your Ansible Playbook. Once launched, it will install an Apache ZooKeeper server.

### Prerequisities

#### To execute this role:

Ansible 2.8.1 version installed.

:warning: Inventory destination should be a Debian environment. Notice that you will need to [install Java](https://github.com/idealista/java_role) in that environment after execute this role.

#### For testing purposes:

* \>= Python 2.7 
* [Pipenv](https://github.com/pypa/pipenv) 
* [Docker](https://www.docker.com/) as driver

:warning: As this role is ready to use in production, the image hosted in [Docker Hub]((https://hub.docker.com/r/idealista/zookeeper/)) is only for testing purposes. That image is deployed using *rolling tags* and major changes could break your tests. 

**We strongly do not recommend to use containers in production based on that image** (maybe it will be ready in future releases). 

### Installing

Create or add to your roles dependency file (e.g requirements.yml):

```
- src: idealista.zookeeper_role
  version: 1.5.0
  name: zookeeper
```

Install the role with ansible-galaxy command:

```
ansible-galaxy install -p roles -r requirements.yml -f
```

Use in a playbook:

```
---

- hosts: someserver
  roles:
    - zookeeper
```

## Usage

To set multiple versions

```
zookeeper_hosts:
  - host: zookeeper1
    id: 1
  - host: zookeeper2
    id: 2
  - host: zookeeper3
    id: 3
```

## Testing


```sh
$ pipenv install -r test-requirements.txt --python 2.7
$ pipenv run molecule test
```

## Built With

![Ansible](https://img.shields.io/badge/ansible-2.8.1-green.svg)

## Versioning

For the versions available, see the [tags on this repository](https://github.com/idealista/zookeeper_role/tags).

Additionaly you can see what change in each version in the [CHANGELOG.md](CHANGELOG.md) file.

## Authors

* **Idealista** - *Work with* - [idealista](https://github.com/idealista)

See also the list of [contributors](https://github.com/idealista/zookeeper_role/contributors) who participated in this project.

## License

![Apache 2.0 License](https://img.shields.io/hexpm/l/plug.svg)

This project is licensed under the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license - see the [LICENSE](LICENSE) file for details.

## Contributing

Please read [CONTRIBUTING.md](.github/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.
