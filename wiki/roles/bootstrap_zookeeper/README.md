```markdown
---
title: Apache ZooKeeper Ansible Role
original_path: roles/bootstrap_zookeeper/README.md
category: Ansible Roles
tags: [Apache ZooKeeper, Ansible, Debian]
---

# Apache ZooKeeper Ansible Role

This Ansible role installs an Apache ZooKeeper service in a Debian environment.

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installing](#installing)
- [Usage](#usage)
- [Testing](#testing)
- [Built With](#built-with)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)
- [Contributing](#contributing)
- [Backlinks](#backlinks)

## Getting Started

These instructions will get you a copy of the role for your Ansible Playbook. Once launched, it will install an Apache ZooKeeper server.

### Prerequisites

#### To execute this role:

- Ansible 2.8.1 version installed.
  
  :warning: The inventory destination should be a Debian environment. Note that you will need to [install Java](https://github.com/idealista/java_role) in that environment after executing this role.

#### For testing purposes:

- Python 2.7 or later
- [Pipenv](https://github.com/pypa/pipenv)
- [Docker](https://www.docker.com/) as driver

  :warning: As this role is ready for production use, the image hosted on [Docker Hub](https://hub.docker.com/r/idealista/zookeeper/) is only intended for testing purposes. This image uses *rolling tags*, and major changes could break your tests.

  **We strongly recommend against using containers in production based on that image** (this may change in future releases).

### Installing

Create or add to your roles dependency file (e.g., `requirements.yml`):

```yaml
- src: bootstrap_zookeeper
  version: 1.5.0
  name: bootstrap_zookeeper
```

Install the role using the `ansible-galaxy` command:

```sh
ansible-galaxy install -p roles -r requirements.yml -f
```

Use in a playbook:

```yaml
---
- hosts: someserver
  roles:
    - bootstrap_zookeeper
```

## Usage

To set multiple versions, define the `zookeeper_hosts` variable as follows:

```yaml
zookeeper_hosts:
  - host: zookeeper1
    id: 1
  - host: zookeeper2
    id: 2
  - host: zookeeper3
    id: 3
```

## Testing

To run tests, execute the following commands:

```sh
$ pipenv install -r test-requirements.txt --python 2.7
$ pipenv run molecule test
```

## Built With

- [Ansible](https://www.ansible.com/)
- [Docker](https://www.docker.com/)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your-repository/tags).

## Authors

- **Author Name** - *Initial work* - [GitHub Profile](https://github.com/author-profile)

See also the list of [contributors](https://github.com/your-repository/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Backlinks

- [Ansible Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
```

Make sure to replace placeholders like `your-repository` and `author-profile` with actual values relevant to your project.