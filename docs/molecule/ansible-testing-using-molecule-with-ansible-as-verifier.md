
# Ansible Testing Using Molecule with Ansible as Verifier

In this tutorial, we would be learning how to test infrastructure code written in Ansible using a testing framework known as Molecule. Inside Molecule we would be making use of Ansible as our verifier which is something I wasn’t able to find anywhere yet. Let’s do this!

## Table of Contents

-   [1. Introduction](#1-introduction)
-   [2. Installing Molecule](#2-installing-molecule)
-   [3. Initialising Molecule in Ansible Roles](#3-initialising-molecule-in-ansible-roles)
-   [4. Writing Ansible Tests with Ansible Verifier](#4-writing-ansible-tests-with-ansible-verifier)
-   [5. Conclusions](#5-conclusions)

## 1. Introduction

**Ansible** is an Open-source IT automation tool used in Configuration Management, Application Deployment, Infrastructure Service Orchestration, Cloud Provisioning and many more. It is an easy-to-use tool yet makes very complex repetitive IT automation tasks look easy. It can be used for multi-tier IT application deployment.

Just like in any other IT sphere, testing is inevitable. An untested infrastructure can be easily written off as an already broken infrastructure. By testing infrastructure code, we ensure the development of production-grade infrastructure code that is void of errors and bugs which can be very costly if not discovered before production.

**Molecule** is a framework designed to aid the development and testing of roles in Ansible. As of September 26, Ansible announced its adoption of Molecule and Ansible-lint as an official Red Hat Ansible projects. This shows the confidence the Red Hat community has in this tool and the amount of work they are putting into making it even better and better.

Molecule makes it possible to test roles across different instances, operating systems and distributions, virtualisation providers, test frameworks and testing scenarios.  
Molecule supports a TDD-like form of testing infrastructure code. In this tutorial, we would look at the lifecycle that molecule testing should follow, according to my opinion.

## 2. Installing Molecule

It is assumed that the reader already has some experience with package management on UNIX systems.

Molecule requires the following packages to function:

-   Python 2.7 or Python 3.5 or greater (For this tutorial, we would be using Python 3.7)
-   Ansible 2.5 or greater (For this tutorial, we would be using Ansible 2.9.6)
-   Docker (latest version)

Pip is the only officially supported package manager for the installation of Molecule. If you’re using Python 2.7.9 (or greater) or Python 3.4 (or greater), then PIP comes installed with Python by default.

To install Molecule using pip:

```shell
$ pip3 install molecule
```

See [molecule installation](https://molecule.readthedocs.io/en/latest/installation.html) for more installation tips. To check if molecule was properly installed, run `$ molecule --version`.

When testing Ansible Playbooks, it is important to understand that we do **not** test that Ansible works, i.e that Ansible has done its job of, for example, creating a file, a user or a group, rather what we test is that our intent, as expressed in plain English, corresponds to Ansible’s declarative language, i.e what has been created is exactly what we wished to create and there was no human errors (e.g, typographical errors or omissions).

## 3. Initialising Molecule in Ansible Roles

There are two ways of initialising Molecule for testing Ansible roles:

**a. Initiating Molecule with a new Ansible Role**  
Molecules makes use of [Ansible Galaxy](https://galaxy.ansible.com/) to generate the standard Ansible role layout. To create a new role with Molecule:

```shell
$ molecule init role <the_role_name>
```

**b. Initiating Molecule for an already existing Ansible role**  
Molecule can also be used to test already existing roles, simply enter the following command in the root directory where the role is located or inside the role directory making sure that the role names match:

```shell
$ molecule init scenario -r <the_already_existing_role_name>
```

Regardless of how you initialise Molecule, a new Molecule folder is added to the root folder of the project. The resulting folder layout is as follows:

```output
.
├── README.md
├── files/                                                
├── handlers/                                              
├── meta/                                                            
├── tasks/                                                 
├── templates/                                              
├── tests/                                               
├── vars/                                              
└── molecule/
        └── default                        
                ├── molecule.yml                        
                ├── converge.yml                        
                ├── verify.yml                                               
                └── INSTALL.rst
```

Below we would discuss the contents of the Molecule folder and their usage:

### molecule.yml

In the molecule.yml, we specify all the molecule configuration needed to test the roles.

```yaml
---
dependency:
  name: galaxy
  enabled: true # to disable, set to false
driver:
  name: docker
platforms:
  - name: instance
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```

**dependency:**  
This is the dependency manager which is responsible for resolving all role dependencies. Ansible Galaxy is the default dependency used by Molecule. Other dependency managers are Shell and Gilt. By default, dependency  is set to true, but can be disabled by setting enabled to false.

**driver:**  
_Driver_ tells Molecule where we want our test instances to come from. Molecule’s default driver is Docker but also has other options such as: AWS, Azure, Google Cloud, Vagrant, Hetzner Cloud and many more. See molecule drivers for more on this.

**platforms:**  
The _platforms_ key indicate what type of instances we want to launch to test our roles. This should correspond to the driver, for example, in the above snippet, it says what type of docker image we want to launch.

**provisioner:**  
The _provisioner_ is the tool that runs the converge.yml file against all launched instances (specified in platforms). The only supported provisioner is Ansible.

**verifier:**  
The _verifier_ is the tool that validates our roles. This verifier runs the verify.yml file to assert that our instance’s actual state (converge state) matches the desired state (verify state). The default verifier is Ansible but there are also other verifiers, such as: testinfra, goss and inspec. Earlier, testinfra was the default verifier but because of the need for a unified testing UX and to avoid the need to learn another language, Python, in the case of testinfra, the community has decided that Ansible becomes the default verifier and I support this decision. See git issue [here](https://github.com/ansible-community/molecule/issues/2013).

Additional keys that are not generated by default are lint and scenario. These keys can be added to the molecule.yml file at will.

**lint:**  
_Lint_ represents what tool Molecule must use to ensure that declarative errors, bugs, stylistic errors, and suspicious constructs are spotted and flagged. Popular lints are yamllint, ansible-lint, flake8, etc.

**scenario:**  
_Scenario_ describes the lifecycle of the Molecule test. The test scenario is customisable as the steps in the sequence can be interchanged or commented out to suit whatever scenario needed. Every role should have a default scenario which is called _default_.  
Unless otherwise stated, the scenario name is usually the name of the directory where the Molecule files are located. Below is the default scenario run when we run the corresponding command sequence:

```yaml
scenario:
  create_sequence:
    - dependency
    - create
    - prepare
  check_sequence:
    - dependency
    - cleanup
    - destroy
    - create
    - prepare
    - converge
    - check
    - destroy
  converge_sequence:
    - dependency
    - create
    - prepare
    - converge
  destroy_sequence:
    - dependency
    - cleanup
    - destroy
  test_sequence:
    - dependency
    - lint
    - cleanup
    - destroy
    - syntax
    - create
    - prepare
    - converge
    - idempotence
    - side_effect
    - verify
    - cleanup
    - destroy
```

From they above snippet, we can tell what happens when we run a Molecule command, for example, `$ molecule create` would run then _create_sequence_ while `$ molecule check` would run the _check_sequence and so on_.

In general, we only add the _scenario_ key when we want to customise our scenario else it is unnecessary as it is the default scenario and hence, implicit.

### converge.yml

The converge.yml file, just as the name implies, is used to convert the state of the instances to the real state declared in the actual roles to be tested. It runs the single converge play on the launched instances. This file is run when we run the `$ molecule converge` command.

### verify.yml

The verify.yml file runs the play that calls the test roles. These roles are used to validate that the already converged instance state matches the desired state. This file is run when we run the `$ molecule verify` command.

### INSTALL.rst

This file contains instructions for additional dependencies needed for a successful interaction between Molecule and the driver.

## 4. Writing Ansible Tests with Ansible Verifier

In this section, we would practice what in my opinion should be the workflow for testing Ansible roles using the Ansible verifier in Molecule.

Running `$ molecule test` runs the entire _test_sequence_ but always destroys the created instance(s) at the end and this can consume a lot of time considering we have to recreate the instances everytime we make changes to our actual or test roles.  
Therefore, the workflow to follow which suits the Given-When-Then approach of BDD is:

```shell
# given phase
$ molecule create

# when phase
$ molecule converge

# then phase
$ molecule verify
```

In the above snippet, the _given_ phase doesn't often change, so we just create the instance(s) once. After that, we iterate between when and then phases until our tests are all verified and error free.

In this tutorial, our goal is to implement TDD while testing our infrastructure. We would be writing unit tests. So say we wanted to implement a role called  _alpha-services_, that accomplished the following tasks:

-   **Task 1**: Installs Java-1.8 on the host machine
-   **Task 2**: Creates a dir at path /var/log/tomcat belonging to owner ‘tomcat’, group ‘tomcat’ and of mode ‘0755’
-   **Task 3**: Installs, starts and enables httpd
-   **Task 4**: Copy a template file from template/tomcat/context.xml to /etc/tomcat/context.xml

First, we create the role using the molecule init command:

```shell
$ molecule init role alpha-services
```

This creates a similar folder layout as shown earlier. Next, we create `alpha-services/molecule/default/roles/test_alpha-services` path:

```shell
$ cd alpha-services
$ mkdir -p molecule/default/roles/test_alpha-services
```

This is where our test roles would be contained. Inside _test_alpha-services_ directory, we create our test roles using the standard Ansible role layout (we create only the folders that we require for testing, in this case, defaults, tasks and vars). Each created folder should have its main.yml file. For the individual task, we would create separate yml files to differentiate them for each other, prefixing _test__ to the task name. For example, the task to install java would be called `test_java.yml`.

```shell
$ cd molecule/default/roles/test_alpha-services
$ mkdir defaults && touch defaults/main.yml
$ mkdir tasks && touch tasks/main.yml tasks/test_java.yml tasks/test_tomcat.yml tasks/test_httpd.yml tasks/test_aws.yml
$ mkdir vars && touch vars/main.yml
```

We would then be left with the following folder layout:

```shell
alpha-services/
        ├── README.md
        ├── files/                                                
        ├── handlers/                                              
        ├── meta/                                                            
        ├── tasks/                                                 
        ├── templates/                                              
        ├── tests/                                               
        ├── vars/                                              
        └── molecule/
                └── default                        
                        ├── molecule.yml                        
                        ├── converge.yml                        
                        ├── verify.yml                                               
                        ├── INSTALL.rst                       
                        └── roles/    
                              └── test_alpha-services/                        
                                        ├── defaults/                        
                                              └── main.yml                                               
                                        ├── tasks/                        
                                              ├── main.yml 
                                              ├── test_java.yml                        
                                              ├── test_tomcat.yml                        
                                              ├── test_httpd.yml                                               
                                              └── test_aws.yml      
                                        └── vars/                        
                                              └── main.yml

```

We configure the molecule.yml file:

```yaml
---
dependency:
  name: galaxy
  enabled: false
driver:
  name: docker
platforms:
  - name: instance
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```

We leave the converge.yml file as is:

```yaml
---
- name: Converge
  hosts: all
  tasks:
    - name: "Include alpha-services"
      include_role:
        name: "alpha-services"
```

We edit the verify.yml file to include our test_provisioner role:

```yaml
---
# This is an example playbook to execute Ansible tests.
- name: Verify
  hosts: all
  tasks:
    - name: "Include test_alpha-services"
      include_role:
        name: "test_alpha-services"
```

GIVEN PHASE: We run `$ molecule create` to create the instances.

```shell
$ molecule create

--> Test matrix
    
└── default
    ├── dependency
    ├── create
    └── prepare
    
--> Scenario: 'default'
--> Action: 'dependency'
Skipping, dependency is disabled.
--> Scenario: 'default'
--> Action: 'create'
--> Sanity checks: 'docker'
    
    PLAY [Create] ******************************************************************
    
    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None) 
    
    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item=None)
    ok: [localhost]
    
    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item=None) 
    
    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item=None)
    ok: [localhost]
    
    TASK [Build an Ansible compatible image (new)] *********************************
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7) 
    
    TASK [Create docker network(s)] ************************************************
    
    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item=None)
    ok: [localhost]
    
    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=instance)
    
    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    changed: [localhost] => (item=None)
    changed: [localhost]
    
    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
    
--> Scenario: 'default'
--> Action: 'prepare'
Skipping, prepare playbook not configured.

```

WHEN PHASE: We run `$ molecule converge` to run the actual roles which are yet to be implemented. This doesn't affect any change on the created instance.

```shell
$ molecule converge

--> Test matrix
    
└── default
    ├── dependency
    ├── create
    ├── prepare
    └── converge
    
--> Scenario: 'default'
--> Action: 'dependency'
Skipping, dependency is disabled.
--> Scenario: 'default'
--> Action: 'create'
Skipping, instances already created.
--> Scenario: 'default'
--> Action: 'prepare'
Skipping, prepare playbook not configured.
--> Scenario: 'default'
--> Action: 'converge'
--> Sanity checks: 'docker'
    
    PLAY [Converge] ****************************************************************
    
    TASK [Gathering Facts] *********************************************************
    ok: [instance]
    
    TASK [Include alpha-services] **************************************************
    
    TASK [alpha-services : include java installation tasks] ************************
    included: /Users/chukwudiuzoma/Documents/DevOps/ANSIBLE/MyTutorials/AnsibleTestingWithMolecule/alpha-services/tasks/java.yml for instance
    
    TASK [alpha-services : Install java] *******************************************
    changed: [instance]
    
    PLAY RECAP *********************************************************************
    instance                   : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Now we go ahead to develop the roles.  
Following TDD approach, we first create the tests and check that they fail before implementing the roles that they are testing.

#### **TASK 1: Install Java-1.8.0 on the host machine**

alpha-services/molecule/default/roles/test_alpha-services/tasks/test_java.yml:
```yaml
---
- name: "java - check Java package status"
  package:
    name: "java-1.8.0"
    state: "installed"
  check_mode: yes
  register: pkg_status

- name: "java - test java package is installed"
  assert:
    that:
      - not pkg_status.changed
```

_Check Java package status_ task tries to install `java-1.8.0` in check mode and registers the result of that operation in `pkg_status`.  In actual sense, if `java-1.8.0` is already installed, the assertion `not pkg_status.changed` would return `true` because the state would not have changed.  

We include the `test_java.yml` tasks in `alpha-services/molecule/default/roles/test_alpha-services/tasks/main.yml` file like so:

alpha-services/molecule/default/roles/test_alpha-services/tasks/main.yml:
```yaml
---
- name: "include tasks for testing Java"
  include_tasks: "test_java.yml"
```

THEN PHASE: We run `$ molecule verify`. As expected, it should fail with the following error:

```shell
$ molecule verify

--> Test matrix
    
└── default
    └── verify
    
--> Scenario: 'default'
--> Action: 'verify'
--> Running Ansible Verifier
--> Sanity checks: 'docker'
    
    PLAY [Verify] ******************************************************************
    
    TASK [Gathering Facts] *********************************************************
    ok: [instance]
    
    TASK [Include test_alpha-services] *********************************************
    
    TASK [test_alpha-services : include tasks for testing Java] ********************
    included: /Users/chukwudiuzoma/Documents/DevOps/ANSIBLE/MyTutorials/AnsibleTestingWithMolecule/alpha-services/molecule/default/roles/test_alpha-services/tasks/test_java.yml for instance
    
    TASK [test_alpha-services : Check Java package status] *************************
    changed: [instance]
    
    TASK [test_alpha-services : Test java package is installed] ********************
fatal: [instance]: FAILED! => {
    "assertion": "not pkg_status.changed",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}
    
    PLAY RECAP *********************************************************************
    instance                   : ok=3    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    
ERROR:
```

Now we implement Task 1.  We first create an `alpha-services/tasks/java.yml` file and populate it with the following:

alpha-services/tasks/java.yml:
```yaml
---
- name: "Install '{{ java_required_software }}'"
  package:
    name: "{{ java_required_software }}"
    lock_timeout: 60
    state: "present"
```

We then include the `java.yml` tasks in `alpha-services/tasks/main.yml` file like so:

alpha-services/tasks/main.yml:
```yaml
---
- name: "Include java installation tasks"
  include_tasks: "java.yml"
```

WHEN PHASE: Now we run `$ molecule converge` to effect changes on the instance.

THEN PHASE: Here we run `$ molecule verify` which should pass the test if the `converge` phase was successful.

```shell
$ molecule verify

--> Test matrix
    
└── default
    └── verify
    
--> Scenario: 'default'
--> Action: 'verify'
--> Running Ansible Verifier
--> Sanity checks: 'docker'
    
    PLAY [Verify] ******************************************************************
    
    TASK [Gathering Facts] *********************************************************
    ok: [instance]
    
    TASK [Include test_alpha-services] *********************************************
    
    TASK [test_alpha-services : include tasks for testing Java] ********************
    included: /Users/chukwudiuzoma/Documents/DevOps/ANSIBLE/MyTutorials/AnsibleTestingWithMolecule/alpha-services/molecule/default/roles/test_alpha-services/tasks/test_java.yml for instance
    
    TASK [test_alpha-services : Check Java package status] *************************
    ok: [instance]
    
    TASK [test_alpha-services : Test java package is installed] ********************
    ok: [instance] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    
    PLAY RECAP *********************************************************************
    instance                   : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    
Verifier completed successfully.
```

#### **TASK 2: Create a dir at path `/var/log/tomcat` belonging to owner `tomcat`, group `tomcat` and of mode `0755`**

alpha-services/molecule/default/roles/test_alpha-services/tasks/test_tomcat.yml:
```yaml
---
- name: "tomcat - '{{ test_tomcat_home_dir }}' - retrieve information from path"
  stat:
    path: "{{ test_tomcat_home_dir }}"
  register: directory

- name: "tomcat - assert that directory '{{ test_tomcat_home_dir }}' is created correctly"
  assert:
    that:
      - "directory.stat.exists"
      - "directory.stat.isdir"
      - "directory.stat.mode == {{ test_tomcat_mode }}"
      - "directory.stat.pw_name == {{ test_tomcat_user }}"
      - "directory.stat.gr_name == {{ test_tomcat_group}}"
```

We define the variables in Molecule’s test defaults yml file:

alpha-services/molecule/default/roles/test_alpha-services/defaults/main.yml:
```yaml
---
#TOMCAT
test_tomcat_mode: "0755"
test_tomcat_user: "tomcat"
test_tomcat_group: "tomcat"
test_tomcat_home_dir: "/var/log/tomcat"
```

The first task uses Ansible’s `stat` module to get file system status while the second one checks that the statuses are match.

Next, we include the `test_java.yml` task in `alpha-services/molecule/default/roles/test_alpha-services/tasks/main.yml` file like so:

alpha-services/molecule/default/roles/test_alpha-services/tasks/main.yml:
```yaml
---
- name: "include tasks for testing Tomcat"
  include_tasks: "test_tomcat.yml"
```

After this, we go ahead to run `$ molecule verify` which rightfully fails just like in the previous test. We therefore implement the actual task:

alpha-services/tasks/tomcat.yml:
```yaml
---
- name: "tomcat - create required tomcat logging directory"
  file:
    path: "{{ tomcat_home_dir }}"
    state: "directory"
    mode: "0755"
    owner: "{{ tomcat_user }}"
    group: "{{ tomcat_group }}"
    recurse: yes
```

We define the variables in the actual role’s defaults yml file:

alpha-services/defaults/main.yml:
```yaml
---
#TOMCAT
tomcat_mode: "0755"
tomcat_user: "tomcat"
tomcat_group: "tomcat"
tomcat_home_dir: "/var/log/tomcat"
```

We include the `tomcat.yml` tasks in `alpha-services/tasks/main.yml` file like so:

alpha-services/tasks/main.yml:
```yaml
---
- name: "Include java installation tasks"
  include_tasks: "java.yml"
```

WHEN PHASE: Now we run `$ molecule converge` to affect changes on the instance.  
THEN PHASE: We then run `$ molecule verify` which should pass the test if the `converge` phase was successful.

#### **TASK 3: Install, start and enable httpd**

We will not test this task because Ansible does that for us. As stated in the [Ansible documentation](https://docs.ansible.com/ansible/latest/reference_appendices/test_strategies.html), 
> Ansible resources are models of desired-state. As such, it should not be necessary to test that services are started, packages are installed, or other such things. Ansible is the system that will ensure these things are declaratively true.  

As such, if the service doesn't exit, and we try to start it, the task will fail with the error shown below:

```output
TASK [alpha-services : httpd - start and enable httpd service] *****************
fatal: [instance]: FAILED! => {"changed": false, "msg": "Could not find the requested service httpd: host"}
```

Therefore, we will only implement the task:

alpha-services/tasks/httpd.yml:
```yaml
---
- name: "Httpd - install httpd service"
  package:
    name: "httpd"
    state: "latest"

- name: "Httpd - start and enable httpd service"
  service:
    name: "httpd"
    state: "started"
    enabled: "yes"
```

It is worth noting that running `httpd` on a linux systems requires `systemd` which is not present by default in docker containers. To be able to start a service on the docker container, we add the following edited platforms key in the `molecule.yml` file:

alpha-services/molecule/default/molecule.yml:
```yaml
---
platforms:
  - name: instance
    image: docker.io/pycontribs/centos:7
    pre_build_image: false # we don't need ansible installed on the instance
    command: /sbin/init
    tmpfs:
      - /run
      - /tmp
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    privileged: true
```

For more information on running systemd, see [link](https://molecule.readthedocs.io/en/latest/examples.html).  
We now run `$ molecule create` and `$ molecule converge`. If they both run successfully then the `httpd` service is up and running. To manually check for the `httpd` service, we run:

```shell
$ molecule login         # this logs you into the docker container shell

$ systemctl | grep httpd
httpd.service loaded active running The Apache HTTP Server

$ exit                  # this logs you out of the docker container to your local terminal
```

#### **TASK 4: Copy a template file from `template/tomcat/context.xml` to `/etc/tomcat/context.xml`**

Just like before, what we will be testing here is the existence of the exact file that we want to copy from the controller to the host system. We want to test that the file name is what we expect and probably some specific contents of the file are present as expected. We could have made an error while naming the file or creating the file contents and these are what we need to check. By default, if the file is not copied, Ansible would let us know.

We add the following to their respective files:

alpha-services/molecule/default/roles/test_alpha-services/tasks/test_tomcat.yml:
```yaml
- name: "tomcat - test tomcat file"
  block:
    - name: "tomcat - retrieve information from path '{{ test_tomcat_context_xml_file }}'"
      stat:
        path: "{{ test_tomcat_context_xml_file }}"
      register: remote_file
    - name: "tomcat - assert that '{{ test_tomcat_context_xml_file }}' file is created correctly"
      assert:
        that:
          - "remote_file.stat.exists"
          - "remote_file.stat.isreg" # is a regular file
          - "remote_file.stat.path == '{{ test_tomcat_context_xml_file }}'"
          - "remote_file.stat.mode == '0755'"
```

alpha-services/molecule/default/roles/test_alpha-services/defaults/main.yml:
```yaml
test_tomcat_conf_dir: "/etc/tomcat"
test_tomcat_context_xml_file: "{{ test_tomcat_conf_dir }}/context.xml"
```

After this, we run `$ molecule verify` to see that it fails. After that, we implement the actual tasks:

alpha-services/tasks/tomcat.yml:
```yaml
- name: "tomcat - copy dynamic tomcat server config files"
  template:
    src: "{{ tomcat_context_xml_file }}"
    dest: "{{ tomcat_conf_dir }}"
```

alpha-services/defaults/main.yml:
```yaml
tomcat_conf_dir: "/etc/tomcat"
tomcat_context_xml_file: "tomcat/context.xml"
```

We then run `$ molecule converge` and `$ molecule verify` subsequently. The tests should pass if everything was done right.

Finally, just to be sure, we run the `$ molecule test` to execute the entire Molecule _test_sequence_. Everything should run smoothly without any errors.

## 5. Conclusions

In conclusion, in my opinion, this is the right approach to developing Molecule tests for ansible roles. Infrastructure code should be tested before being deployed in production to avoid unpleasant surprises. This tutorial has been a simple demonstration of how Ansible testing can be done with Molecule using Ansible verifier. This way there is no need to learn another programming language such as Python, Ruby or Go.

## Reference

* https://www.adictosaltrabajo.com/2020/05/08/ansible-testing-using-molecule-with-ansible-as-verifier/
* 