
[![](./molecule1.png?w=1024)]

## Why Molecule?

Have you ever faced issue that your Ansible code gets executed successfully but something went wrong like, service is not started, the configuration is not getting changed, etc?

There is another issue which you might have faced, that your code is running successfully on Redhat 6 but not running successfully on Redhat 7, to make your code smart enough to run on every Linux flavour, in order to achieve this, molecule came into the picture. Let’s start some brainstorm in Molecule.

Molecule has capability to execute YML linter and custom test cases which you have written for your Ansible code. We will explain the linter and test cases below

## Why code testing is required?

Sometimes during the playbook execution, although it executes playbook fine but it does not give us the desired result so in order to check this we should use code testing in Ansible.

In general, code testing helps developer to find bugs in code/application and make sure the same bugs don’t cause the application to break. it also helps us to deliver application/software as per standard of code. code testing helps us to increase code stability.

## Introduction :

This whole idea is all about to use Molecule (A testing tool) you can test your Ansible code whether it’s functioning correctly on all Linux flavour including all its functionalities or not.

Molecule is a code linter program that analyses your source code for potential errors. It can detect errors such as syntax errors; structural problems like the use of undefined variables, etc.

The molecule has capabilities to create a VM/Container environment automatically and on top, it will execute your ansible code to verify all its functionalities.

Molecule Can also check syntax, idempotency, code quality, etc

Molecule only support Ansible 2.2 or latest version

NOTE: To run ansible role with the molecule in different OS flavour we can use the cloud, vagrant, containerization (Docker)  
Here we will use Docker……………………

Let’s Start……………

## How Molecule works:

“When we setup molecule a directory with name “molecule” creates inside ansible role directory then it reads it’s main configuration file “molecule.yml” inside molecule directory. Molecule then creates platform (containes/Instances/Servers) in your local machine once completed it executes Ansible playbook/role inside newly created platform after successful execution, it executes test cases. Finally Molecule destroy all newly created platform”

[![](./molecule-1.png?w=900)]

## Installation of Molecule:

Installation of the molecule is quite simple.

```shell
$ sudo apt-get update
$ sudo apt-get install -y python-pip libssl-dev
$ pip install molecule [ Install Molecule ]
$ pip install --upgrade --user setuptools [ do not run in case of VM ]
```

That’s it…………

Now it’s time to setup Ansible role with the molecule. We have two option to integrate Ansible with molecule:

1.  With New Ansible role
2.  with existing Ansible role

## 1\. Setup new ansible role with molecule:

```shell
$ molecule init role --role-name ansible-role-nginx --driver-name docker
```

When we run above command, a molecule directory will be created inside the ansible role directory

## 2\. Setup the existing ansible role with molecule:

Goto inside ansible role and run below command.

```shell
$ molecule init scenario --driver-name docker
```

When we run above command, a molecule directory will be created inside the ansible role directory

NOTE: Molecule internally uses ansible-galaxy init command to create a role

Below is the main configuration file of the molecule:

-   molecule.yml – Contains the definition of OS platform, dependencies, container platform driver, testing tool, etc.
-   playbook.yml – playbook for executing the role in the vagrant/Docker
-   tests/test\_default.py | we can write test cases here.

## Content of molecule.yml

cat molecule/default/molecule.yml

```yaml
---
molecule:
  ignore_paths:
    - venv
 
dependency:
  name: galaxy
driver:
  name: docker
lint:
  name: yamllint    
platforms:
  - name: centos7
    image: centos/systemd:latest
    privileged: True
  - name: ubuntu16
    image: ubuntu:16.04
provisioner:
  name: ansible
  lint:
    name: ansible-lint
#    enabled: False
verifier:
  name: testinfra
  lint:
    name: flake8
scenario:
  name: default  # optional
  create_sequence:
    - create
    - prepare
  check_sequence:
    - destroy
    - dependency
    - create
```

## Explanation of above contents:

### Dependency:

Testing roles may rely upon additional dependencies. Molecule handles managing these dependencies by invoking configurable dependency managers.

“Ansible Galaxy” is the default dependency manager.

### Linter:

A linter is a problem which analyses our code for potential errors.

### What code linters can do for you?

Code linter can do:

1.  Syntax errors;
2.  Check for undefined variables;
3.  Best practice or code style guideline.
4.  Extra lines.
5.  Extra spaces. etc

\*\*We have linters for almost every programming languages like we have yamllint for YAML languages, etc.

**yamllint:** It checks for syntax validity, key repetition, lines length, trailing spaces, indentation, etc.

provisioner: Ansible is the default provisioner. No other provisioner will be supported.

**Flake8:**– is the default verifier linter. Usage python file

## platforms:

What platform (Containers) will be created and Ansible code will be executed.

## Driver:

Driver defines your platform where your Ansible code will be executed

**Molecule supports below drivers:**

-   Azure
-   Docker
-   EC2
-   GCE
-   Openstack
-   Vagrant

## **Scenario**:

**Scenario** – scenario defines what will be performed when we run molecule

**Below is the default scenario:**

–> Test matrix

└── default  
├── lint  
├── destroy  
├── dependency  
├── syntax  
├── create  
├── prepare  
├── converge  
├── idempotence  
├── side\_effect  
├── verify  
└── destroy

However, we can change this scenario and sequence by changing molecule.yml file :

```yaml
scenario:
  name: default  # optional
  create_sequence:      # molecule create 
    - create
    - prepare
  check_sequence:       # molecule check 
    - destroy
    - dependency
    - create
    - prepare
    - converge
    - check
    - destroy
  converge_sequence:    # molecule converge 
    - dependency
    - create
    - prepare
    - converge
  destroy_sequence:     # molecule destroy 
    - cleanup
    - destroy
  test_sequence:        # molecule test 
#    - lint
    - cleanup
    - dependency
    - syntax
    - create
    - prepare
    - converge
```

NOTE: If anyone scenario (action) fails, others will not be executed. this is the default molecule behaviour

## Here I am defining all the scenarios:

**lint:** Checks all the YAML files with yamllint

**destroy**: If there is already a container running with the same name, destroy that container

**Dependency**: This action allows you to pull dependencies from ansible-galaxy if your role requires them

**Syntax**: Checks the role with ansible-lint

**create:** Creates the Docker image and use that image to start our test container.

**prepare:** This action executes the prepare playbook, which brings the host to a specific state before running converge. This is useful if your role requires a pre-configuration of the system before the role is executed.

**Example:** prepare.yml

```yaml
---
- name: Prepare
  hosts: all
  gather_facts: false
  tasks:
    - name: Install net-tools curl
      apt: 
        name: ['curl', 'net-tools']
        state: installed 
      when: ansible_os_family == "Debian"
```

**NOTE:** when we run “molecule converge” below task will be performed :

\====> Create –> create.yml will be called  
\====> Prepare –> prepare.yml will be called  
\====> Provisioning –> playbook.yml will be called

**converge:** Run the role inside the test container.

**idempotence:** molecule runs the playbook a second time to check for idempotence to make sure no unexpected changes are made in multiple runs:

**side\_effect:** Intended to test HA failover scenarios or the like. See Ansible provisioner

**verify:** Run tests inside the container which we have written

**destroy:** Destroys the created container

**NOTE:** When we run molecule commands, a directory with name molecule created inside /tmp which is molecule managed, which contains ansible configuration, Dockerfile for all linux flavour and ansible inventory

cd /tmp/molecule

tree  
.  
└── osm\_nginx  
└── default  
├── ansible.cfg  
├── Dockerfile\_centos\_systemd\_latest  
├── Dockerfile\_ubuntu\_16\_04  
├── inventory  
│ └── ansible\_inventory.yml  
└── state.yml

**state.yml** :- maintain scenario which has been performed .

```output
Molecule managed

---
converged: true
created: true
driver: docker
prepared: true
```

## Testing:

This is is most important part of Molecule where we will write some test cases.

Testinfra is the default test runner.

Below module should be installed:

-   $ **pip install testinfra**
-   $ **molecule verify**

Molecule calls below file for unit test using “testinfra” verifier

molecule/default/tests/test\_default.py

## verifier:

**Verifier** is used for running your test cases.

Below are the three verifiers which we can use in Molecule

-   **testinfra** – It usage python language for writing test cases.
-   **goss** – It usage yml language for writing test cases.
-   **serverspac** – usage ruby language for writing test cases.

Here I am using **testinfra** as verifier for writing test case.

## Molecule commands:

-   \# molecule check \[ Run playbook.yml in check mode \]
-   \# molecule create \[ Create instance/ Platform\]
-   \# molecule destroy \[ destroy instance / Platform\]
-   \# molecule verify \[ perform unit test \]
-   \# molecule test \[ It performs below default scenario in sequence \]
-   \# molecule prepare
-   #molecule converge

**NOTE**: To enable logs to run a command with –debug flag

$ molecule –debug test

## Sample Test cases :

cat molecule/default/tests/test\_default.py

```python
import os
 
import testinfra.utils.ansible_runner
 
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')
 
def test_user(host):
    user = host.user("www-data")
    assert user.exists
 
def test_nginx_is_installed(host):
    nginx = host.package("nginx")
    assert nginx.is_installed
 
 
def test_nginx_running_and_enabled(host):
  os = host.system_info.distribution
  if os == 'debian':
    nginx1 = host.service("nginx")
    assert nginx1.is_running
    assert nginx1.is_enabled
 
def test_nginx_is_listening(host):
    assert host.socket('tcp://127.0.0.1:80').is_listening
```


That's all for now.  We have created an environment for Molecule and test cases.

## Links you may refer:

* [https://yamllint.readthedocs.io/en/stable/](https://yamllint.readthedocs.io/en/stable/)
* [how-to-test-ansible-playbook-role-using-molecule-with-docker/](https://blog.opstree.com/2019/12/24/how-to-test-ansible-playbook-role-using-molecule-with-docker/)

