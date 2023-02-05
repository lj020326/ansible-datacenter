
# Using molecule to test ansible in docker with systemd

Docker comes without the ability to use systemd without making some changes to the Dockerfile and the volumes passed to the container created.

But sometimes you face some challenges on which you have to test some ansible roles that were not meant to be used against Docker containers.

## [How to test ansible-roles properly](#Using-molecule-with-docker.html#how-to-test-ansible-roles-properly)

If you haven’t yet had to test your ansible roles before targeting your production machine you have been lucky. Lucky because you haven’t had to test it, and lucky because you haven’t screwed up yet, but let me tell you.. You will as we all do and its better to properly test your ansible roles before targeting some of your production hosts with an untested ansible role, imagine some firewall rules in your firewall setting role, just killing ssh port..

So if you ever come to the point of testing ansible there are a few ways to do it, I prefer using molecule these days, but had a rough start with it, taking a dive in molecule with docker as a provider, and testing some ansible-roles with systemd usage in it.

## [Installing molecule](#Using-molecule-with-docker.html#installing-molecule)

Well let’s not get into the details of installing molecule, but for using it in systemd, I would avoid molecule in DIND (Docker in Docker) as you will enter a volume loop and permissions hell. Remeber systemd is only available by making cgroups available to the running container as a volume.

Use the virtualenv snippet below, or find out more ways at https://molecule.readthedocs.io/en/latest/installation.html

This snippet requires you to have virtualenv installed

```shell
virtualenv env --python python3
source env/bin/activate
pip install molecule
```

You must have the following dependencies installed

Centos

`libffi-devel git`

Ubuntu

`libffi-dev git`

## [Creating a Centos7 Docker image that supports Systemd to be used with Molecule](#Using-molecule-with-docker.html#creating-a-centos7-docker-image-that-supports-systemd-to-be-used-with-molecule)

We had a few moments @fiercely (where I work) where we required a systemd enabled Docker image for usage with Vagrant for instance and others ( a later post will be done on how to use with vagrant) so we had the need to create one. You may use it as you will.

Source is available at: https://github.com/Fiercely/centos7 under MIT LICENSE

But for easier viewing I’ll leave it here below in a code snippet.

```Dockerfile
FROM centos:centos7
LABEL maintainer="andre.ilhicas@fiercely.pt"
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs initscripts
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
```

This is highly inspired by other Dockerfiles, we are not reiventing the wheel here.

The image is also posted on hub.docker.com under `fiercely/centos7:systemd`

## [Attaching molecule to a an already existing Ansible Role](#Using-molecule-with-docker.html#attaching-molecule-to-a-an-already-existing-ansible-role)

```shell
molecule init scenario --scenario-name molecule-systemd-docker -r $ROLE_PATH
```

> Where $ROLE\_PATH is the folder of an already existing role.

So now we have a scenario, for those who don’t kknow what a scenario in molecule represents its basically a playbook environment with a given inventory, and specific variables, etc.. You may find out more at https://molecule.readthedocs.io/en/latest/usage.html

So now we have a molecule directory inside our role directory, and that directory contains all the scenarios we have now, one the `Default` scenario that molecule creates by default, and the scenario with the name we gave before `molecule-systemd-docker`

## [Setting our Molecule testing scenario to use Centos7 Docker container with Systemd](#Using-molecule-with-docker.html#setting-our-molecule-testing-scenario-to-use-centos7-docker-container-with-systemd)

Under our new scenario we must set the platform molecule is going to use to be Docker, and pass along our cgroups volume to it under

`$ROLE_PATH/molecule/molecule-systemd-docker/molecule.yml`

Now this molecule.yml comes prepopulated with a lot of configurations, and for those already familar with ansible it should be quite easy to under the `yml` configuration structure.

So under the key `platforms` let’s change it to use our image and with the docker arguments to run the containers created.

```yaml
platforms:
  - name: instance-to-test-ansible
    image: fiercely/centos7:systemd
    privileged: True
    volume_mounts:
      - "/sys/fs/cgroup:/sys/fs/cgroup:rw"
    command: "/usr/sbin/init"
```

Ok, now under the same folder, you also have `playbook.yml` that you may customize to your needs, but if you just want it to test the role, the default should be just fine.

If you just want to test it, here is a sample playbook to override the default one.

```yaml
---
- name: Converge
  hosts: all
  roles:
    - role: resmo.ntp
```

This will just test a role named resmo.ntp that sets up NTP via ansible in the Docker container this role requires systemd.

But for that you don’t have that role yet so you must use a `requirements.yml` file to import other roles to be tested alongside your own role.

The `requirements.yml` should live alongside the `playbook.yml` under the scenario. You may also reference other paths under the `molecule.yml` for this particular molecule scenario.

Example requirements.yml to go along the playbook sample

```yaml
- src: resmo.ntp
  version: 0.4.0

```

Now go back to your root folder for the ansible role you will be testing.

And just run

```shell
molecule test --scenario-name molecule-systemd-docker
```

> if using virtualenv don’t forget to have environment set

And molecule will make use of the Docker image to launch a container and the test the ansible role against it.

Molecule will have a series of tests, either the defaults such as the linting, idempotence etc, these are all configurable under the \` molecule.yml\` configuration file for each scenario.

After done with the tests, molecule will destroy the container named `instance-to-test-ansible` described in configuration.

If you wish to keep the container alive after tests have been done, just run the test scenario command with the `--destroy=never` flag, that sometimes is useful for post-mortem analysis or just to interact with the container.

```shell
molecule test --scenario-name molecule-systemd-docker --destroy=never
```

If all goes well your output should look like the one present on github pasted here for easier access.

```output
--> Scenario: 'default'
--> Action: 'create'

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None)

    TASK [Create Dockerfiles from image names] *************************************
    changed: [localhost] => (item=None)

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item=None)

    TASK [Build an Ansible compatible image] ***************************************
    changed: [localhost] => (item=None)

    TASK [Create docker network(s)] ************************************************

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=None)

    TASK [Wait for instance(s) creation to complete] *******************************
    changed: [localhost] => (item=None)

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=4    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'prepare'
Skipping, prepare playbook not configured.
--> Scenario: 'default'
--> Action: 'converge'

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    TASK [resmo.ntp : Add the OS specific variables] *******************************
    ok: [instance]

    TASK [resmo.ntp : Install the required packages in Redhat derivatives] *********
    changed: [instance]

    TASK [resmo.ntp : Install the required packages in Debian derivatives] *********
    skipping: [instance]

    TASK [resmo.ntp : Copy the ntp.conf template file] *****************************
    changed: [instance]

    TASK [resmo.ntp : Start/stop ntp service] **************************************
 [WARNING]: Ignoring "pattern" as it is not used in "systemd"

    changed: [instance]

    RUNNING HANDLER [resmo.ntp : restart ntp] **************************************
    changed: [instance]

    PLAY RECAP *********************************************************************
    instance                   : ok=6    changed=4    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'idempotence'
Idempotence completed successfully.
--> Scenario: 'default'
--> Action: 'side_effect'
Skipping, side effect playbook not configured.
--> Scenario: 'default'
--> Action: 'verify'
--> Executing Testinfra tests found in /CENSORED/tests/...
    ============================= test session starts ==============================
    platform linux2 -- Python 2.7.15rc1, pytest-3.6.2, py-1.5.3, pluggy-0.6.0
    rootdir: /CENSORED/molecule/default, inifile:
    plugins: testinfra-1.12.0
collected 1 item

    tests/test_default.py .                                                  [100%]

    =========================== 1 passed in 5.62 seconds ===========================
Verifier completed successfully.
--> Scenario: 'default'
--> Action: 'destroy'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=None)

    TASK [Wait for instance(s) deletion to complete] *******************************
    changed: [localhost] => (item=None)

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0
```

## Reference

* https://ilhicas.com/2018/08/20/Using-molecule-with-docker.html
* https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container#enter_podman
* 