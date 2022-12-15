
# Ansible testing with molecule and docker on an existing ansible collection

## Overview

Molecule ([https://molecule.readthedocs.io/en/latest/](https://molecule.readthedocs.io/en/latest/)) enables fast and easy testing of ansible roles. In this blog post I will walk through the process of setting up molecule with existing ansible collection.

Sample code can be found here: [https://github.com/Nahid5/molecule-test](https://github.com/Nahid5/molecule-test)

## Installation (Ubuntu)

```shell
sudo apt install -y python3-pip libssl-dev
python3 -m pip install molecule ansible-core
python3 -m pip install --user "molecule[docker,lint]"
```

## Setup

Assuming your ansible collection looks similar to this:

```shell
.
|-- roles
|   |-- rolename
|   |   |-- defaults
|   |   |-- includes
|   |   |-- tasks
|   |   |-- templates
```

We can add in our molecule directly in the `rolename` folder. We will create a `molecules` folder, then inside that folder, we will create a filder named `default`. So the final structure would look something like this:

```shell
.
|-- roles
|   |-- rolename
|   |   |-- defaults
|   |   |-- includes
|   |   |-- tasks
|   |   |-- templates
|   |   |-- molecule
|   |   |   |-- default
```

Inside the default folder we will add in our instructions to setup our container and run our ansible role against the container by creating two files called `converge.yml` and `molecule.yml`.

-   `molecule.yml` is the central configuration entrypoint for Molecule. With this file, you can configure each tool that Molecule will employ when testing your role.
    
-   `converge.yml` is the playbook file that contains the call for your role. Molecule will invoke this playbook with ansible-playbook and run it against an instance created by the driver.
    

First we will create our `converge.yml` file. This file will hold the steps necessary to converge our instances.The `converge` command applies the current version of the role to all the running container instances. Molecule `converge` does not restart the instances if they are already running. It tries to converge those instances by making their configuration match the desired state described by the role currently testing.

```yaml
# Running the requence needed to converge the instance.
- name: Converge
  hosts: all
  tasks:
    - name: "Test Apache"
      include_role:
        name: "apache_server"
```

The converge above will run our role named apache\_server.

The other file we need is the `molecule.yml` file. This file will hold our configurations.

```yaml
# Run the container in bridged mode
dependency:
  name: shell
  command: 'docker network create --driver bridge molecule'
# Using Ansible Galaxy to get other modules
dependency:
  name: galaxy
# Running inside a docker container
driver:
  name: docker
# docker images to use, you can have as many as you'd like
platforms:
  - name: instance
    image: ubuntu:focal
    networks:
      - name: "molecule"
    published_ports:
      80:80
# Run ansible in the docker containers
provisioner:
  name: ansible
# Molecule handles role testing by invoking configurable verifiers.
verifier:
  name: ansible
```

## Command Usage

You must execute the molecule commands from inside the specific role directory.

### Molecule Test
To fully test your ansible role from container creation to, configuration, to destruction, use:

`molecule test`

to run through the process of creating the container, running the ansible script against the container, then destroying the container.

If you would like to manually go through the process then use the following steps to (1) create, (2) converge, (3) test, and (4) destroy. 

### Molecule Create
First create the container using:

`molecule create`

### Molecule Converge
To run the ansible role, use:

`molecule converge`

### Molecule Login
At this point if you would like to interact with the container, use:

`molecule login`

Example:

molecule.yml:
```yaml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance1
    image: docker.io/pycontribs/centos:8
provisioner:
  name: ansible
verifier:
  name: ansible
```

```shell
$ molecule login --host instance1
```

### Molecule Destroy
Lastly, to destroy the container use:

`molecule destroy`

## Reference

* https://whatsyourssn.com/posts/molecule-with-ansible/
* 