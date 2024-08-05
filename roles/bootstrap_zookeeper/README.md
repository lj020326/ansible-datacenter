# Apache ZooKeeper Ansible role 

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
- src: bootstrap_zookeeper
  version: 1.5.0
  name: bootstrap_zookeeper
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
    - bootstrap_zookeeper
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
