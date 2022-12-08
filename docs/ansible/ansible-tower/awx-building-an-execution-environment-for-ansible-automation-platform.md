
# Building an Execution Environment for Ansible Automation Platform

An exciting change to the Ansible Automation Platform is the introduction of [execution environments](https://www.redhat.com/en/technologies/management/ansible/automation-execution-environments), which will help our automation run more consistently wherever we need to automate. Instead of having Ansible Controller grab our required roles and collections, we can [build an execution environment](https://developers.redhat.com/ansiblefest/2020/using-ansible-execution-environments) containing the various components we’d like to leverage.

First, let’s get ansible-builder installed: 

```shell
$ yum -y install ansible-builder

```

This command will install ansible-builder, podman, and a few other components we’ll need to build our execution environment.

The other prerequisite is to login to Red Hat’s image registry: podman login registry.redhat.io, and provide your username and password when prompted. For more information, check out the [container how-to guide](https://access.redhat.com/containers/guide#howto).

Now, we simply need to define what we want our execution environment to contain. Let’s first set up our execution-environment.yml file:

```yaml
---

version: 1

ansible_config: 'ansible.cfg'

build_arg_defaults:
  EE_BASE_IMAGE: 'registry.redhat.io/ansible-automation-platform-20-early-access/ee-minimal-rhel8'

dependencies:
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt

additional_build_steps:
  prepend:
    - RUN pip3 install --upgrade pip setuptools
  append:
    - RUN pip3 list installed

```

A few notes here: first we set the Ansible configuration file we’d like to use. Since we’re pulling content from a few different sources, such as Automation Hub, we need to provide appropriate tokens to access the content. Here’s an example configuration file:

```
[galaxy]
server_list = rh-certified_repo,community_repo,community_galaxy

[galaxy_server.community_repo]
url=https://aap20-hub.josh.lab.msp.redhat.com/api/galaxy/content/community/
token=your-token-here

[galaxy_server.rh-certified_repo]
url=https://aap20-hub.josh.lab.msp.redhat.com/api/galaxy/content/rh-certified/
token=your-token-here

[galaxy_server.community_galaxy]
url=https://galaxy.ansible.com

```

We have a [private instance of Automation Hub](https://www.ansible.com/blog/control-your-content-with-private-automation-hub) running in our environment that we can sync content to.  However, one could also pull content directly from [Automation Hub on console.redhat.com](https://console.redhat.com/ansible/automation-hub/token).

Next, we define the base image to use for our execution environment. Since we’re building this for a specific purpose, I’ve selected the ee-minimal-rhel8 to keep our execution environment small and portable.

After that, we have to define our dependencies, broken out across three files: one describing the Ansible content dependencies (galaxy), the Python dependencies (python), and the system dependencies (system).

First, our Ansible content dependencies, which should look familiar from earlier:

```yaml
roles:
  - name: redhat_sap.sap_hostagent
    source: https://galaxy.ansible.com
  - name: redhat_sap.sap_hana_deployment
    source: https://galaxy.ansible.com
  - name: redhat_sap.sap_s4hana_deployment
    source: https://galaxy.ansible.com
  - name: sap-hana-hsr
    src: https://github.com/jjaswanson4/sap-hana-hsr/archive/refs/tags/v1.3.0.tar.gz
  - name: sap-hana-ha-pacemaker
    src: https://github.com/jjaswanson4/sap-hana-ha-pacemaker/archive/refs/tags/v2.0.0.tar.gz

collections:
  - name: redhat.satellite
  - name: redhat.rhel_system_roles
  - name: sap.rhel

```

In this file, we can define both roles and collections to be included, as Ansible Builder will automatically handle the inclusion of both.

```shell
# python dependencies
jmespath

```

The jmespath python package allows us to use the json\_query filter, which is used as part of the storage role within the RHEL system roles collection.

Finally, our system dependencies:

```shell
# system dependencies
git

```

Because we’re pulling a few roles directly from their source locations on Github, we’ll want the git package.

Finally, I added a few additional build steps, mainly upgrading the pip tooling before building the execution environment, and listing all the python libraries that are installed at the end. These steps aren’t required, but are useful for troubleshooting.

Once complete, we simply tell Ansible Builder to build our execution environment:

```shell
ansible-builder build --tag sap-deployment-ee:1.0.0 -v 3

```

Here I’ve defined what the image should be tagged as after the build is complete, along with a version number, and specified a higher verbosity to get more information as the build progresses. Once complete, we can see our execution environment with the podman images command, as well as re-tag the image and upload it to an appropriate image registry. Once uploaded, we can consume the execution environment from Ansible Controller.

Stay tuned for [Part 6: Setting Up an Inventory in Ansible Automation Platform](https://blogs.sap.com/2021/12/13/part-vi-setting-up-an-inventory-in-ansible-automation-platform/).

## Reference

* https://blogs.sap.com/2021/12/01/part-v-building-an-execution-environment-for-ansible-automation-platform/

