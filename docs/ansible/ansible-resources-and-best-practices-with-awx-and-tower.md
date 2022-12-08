
# Ansible Resources And Best Practices with AWX and Tower

Updated with additional resources such as provisioning and configuring VMs with Ansible Workflows.

I am currently doing a lot of work with Ansible, AWX, Ansible Tower and [Red Hat Satellite](https://www.unixsysadmin.com/category/red-hat-satellite/) to automate and manage a RHEL 6, RHEL 7 and RHEL 8 environment. I’m also deploying VMs outside of our traditional on-premise datacenter using AWS, GCP and VMware vRealize Automation. During that time I bookmarked a number of useful resources and have shared them on this page along with my notes.

## How to provision hosts and manage them with workflows, limits and inventories?

I wanted to use AWX to deploy a number of new VMs (they could be in the cloud, they could be onsite) and then run a set of playbooks against them. The biggest challenge was around the inventory – how to define workflows but dynamically apply a limit after the VM is created. Some links I found really useful:

-   [Reddit thread: AWX Workflow – prompts/limits](https://www.reddit.com/r/ansible/comments/eyiaaj/awx_workflow_promptslimits/)
-   [Reddit thread: Creating a workflow (and playbooks) that only act on the host created in step 1](https://www.reddit.com/r/ansible/comments/cev0ou/creating_a_workflow_and_playbooks_that_only_act/)
-   [Stack Overflow: Ansible: how to call module \`add_host\` for all hosts of the play](https://stackoverflow.com/questions/42106527/ansible-how-to-call-module-add-host-for-all-hosts-of-the-play)
-   [Stack Overflow: Limit hosts using Workflow template](https://stackoverflow.com/questions/52206280/limit-hosts-using-workflow-template)
-   [CI/CD with Ansible Tower and GitHub](https://keithtenzer.com/2019/06/24/ci-cd-with-ansible-tower-and-github/)

The first post suggested using AWX Callbacks. I’ve used these before and there’s further details in this post about using them with Satellite. The idea is that a server comes up for the first time and ‘dials home’ so that a job template can be run against it. The host needs to exist in the inventory. Note, only a template can be called via callback, not a workflow. There’s an open RFE for this – [Issue 1845 RFE: Extend callback feature to workflows](https://github.com/ansible/awx/issues/1845).

However, I’ve not used the callback approach because I have a number of instances which can’t call home such as servers in AWS. What I’ve ended up doing is the following:

-   Create a workflow that is vRA specific and spins up a VMware instance according to my parameters. vRA takes care of creating a DNS record for me and reports back a hostname and IP via the API. A dynamic inventory would likely pick this up straight away. However, I wanted to record some custom parameters (that I’d specified as part of the AWX survey and vRA blueprint) so I use a static inventory (stored in Git). We need to add this new VM to our inventory. As part of the workflow, I have a job template which updates (in Git) these Ansible inventory files. The newly built server goes into a special group ‘provision’.
-   To update this Git repository, I created custom credentials in AWX. These expose a Git username/password as an environment variable when the playbook runs. This username has write access to my Git repository.
-   After the inventory is updated in Git, I need to tell AWX to refresh the inventory. I created a dummy template in my Inventory project which refreshes on launch to do this.
-   Create a second workflow that is similar to the vRA one, but instead spins up an instance on EC2 according to my parameters. Again, I use the same Git job template to update my inventory file in Git, and again it goes to the special group ‘provision’.
-   I create a third workflow which is ‘common’ to all server types. You can think of this as a ‘standard build’. All job templates within this workflow use the inventory source.
-   The last-but-one step of the vRA and AWS workflows call my ‘common’ workflow, and specifies a limit of ‘provision’. This means only my newly built server will be processed.
-   The final steps of the vRA and AWS flows call my Git job template again, but this time removes my server from the ‘provision’ group.

Phew – it was a bit long winded but it means I can add other provisioning methods later and each of them updates a central inventory. All of them calls the same ‘standard build’ workflow so my on premise and remote servers look the same.

## Passing variables in workflows

In the above workflows, I discovered the **set-stats** option in the [Ansible Tower User Guide: Workflows.](https://docs.ansible.com/ansible-tower/latest/html/userguide/workflows.html) Documentation for set-stats is available at [ansible.builtin.set_stats – Set stats for the current ansible run](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/set_stats_module.html)  
How can you use this? Within the job templates that provision AWS EC2 or VMware instances, I can extract data such as hostname, DNS name, IP address or any custom data I want. Using set_stats I set these values and the following jobs in the workflow can reference them – for example adding a hostname to an inventory.

## Launching workflows from within a workflow

I couldn’t figure this out, but there is a module called tower_workflow_launch which should be able to do this: [awx.awx.tower_workflow_launch – Run a workflow in Ansible Tower](https://docs.ansible.com/ansible/latest/collections/awx/awx/tower_workflow_launch_module.html)  
The first use case makes sense: from my terminal I can launch a playbook against AWX/Tower and make it launch a workflow.  
However, if I am already running a job template under AWX contol and I want it to call a workflow it appears as though I need to provide the credentials to AWX from within that first playbook. Perhaps there are some environment variables I can call that can say ‘connect to parent AWX instance’?

## How to use existing Vault files in Ansible?

Links: [How to use existing Vault files in Ansible Tower](https://serverfault.com/questions/878320/how-to-use-existing-vault-files-in-ansible-tower) and [Where to put ansible-vault password](https://devops.stackexchange.com/questions/3282/where-to-put-ansible-vault-password) There are a number of different places where you can store secret data – in AWX/Tower itself, within an Ansible Vault or in an external source. Storing credentials within AWX/Tower is a good idea if you intend to run all jobs through AWX/Tower. If you want the flexibility to run jobs on both the CLI and AWX/Tower then using Ansible Vault is a good idea. However, as per the first link you will likely want to store the Vault in the playbook area rather than the inventory area.

> It is not recommended to keep the vault files with the inventory – as this would mean it decrypts the file every time the inventory sync runs. The way I’ve solved this now is by using “vars_files” in the playbook. It looks like this:
> 
> https://serverfault.com/questions/878320/how-to-use-existing-vault-files-in-ansible-tower

```
  # Secrets
  vars_files:
    - '../../secrets/{{ tower_env }}/vault.yml'
```

> In Tower, I pass in the tower_env variable e.g. “dev” or “qa”, which then decrypts the corresponding vault file when a playbook runs – rather then when syncing inventories.
> 
> https://serverfault.com/questions/878320/how-to-use-existing-vault-files-in-ansible-tower

Also worth mentioning is the fact that Ansible Vault can be brute-forced by an attacker – [https://github.com/stevenharradine/ansible-vault-brute-force/blob/master/ansible-vault-brute-force.sh](https://github.com/stevenharradine/ansible-vault-brute-force/blob/master/ansible-vault-brute-force.sh) – so make sure any Vault password is of significant strength.

## Secret Management with Ansible

Link: [Secret Management with Ansible](https://medium.com/faun/https-medium-com-mikhail-advani-secret-management-with-ansible-3bfdd92472ef) Encrypting your secret data with Ansible Vault is sensible – it means you can control who has access to data which you will only need at runtime (API keys, Database credentials, etc). However, you’ll need to credentials to access the vault itself. This article reviews the advantages of using git-crypt to protect those Vault credentials.

## Add ServiceNow Inventory to AWX/Tower

Link: [Add Custom Dynamic Inventory in Ansible Tower (ServiceNow)](https://averytechguy.com/2018/10/22/add-custom-dynamic-inventory-in-ansible-tower-servicenow/) There are a couple of very useful topics within this article. The first shows how to create a custom credential type within AWX/Tower. Dynamic Inventories will likely use scripts which in turn call APIs. These scripts require credentials and parameters of varying types – keys, username/password combinations, environments (Production, Stage, Test, etc) and so on. A custom credential allows you to define the variables that your script will need. The variables will then be set as environment variables at runtime. The article then goes on to detail how you are able to import your ServiceNow hosts into AWX/Ansible Tower using the [ansible-sn-inventory](https://github.com/ServiceNowITOM/ansible-sn-inventory) script.

## Private Ansible Galaxy

Link: [Private Ansible Galaxy?](https://www.reddit.com/r/ansible/comments/ctuj7h/private_ansible_galaxy/) As you use Ansible more and more, the number of playbooks and roles that need to be managed grows. Ansible-galaxy is a very nice way of making sure that all your custom roles are of a similar standard (You’ll have to enforce a naming convention yourself – see [AWX / Tower Naming Conventions and Best Practice](https://www.reddit.com/r/ansible/comments/d0gdqw/awx_tower_naming_conventions_and_best_practice/)). To initialise a repository:

```
ansible-galaxy init test-role --offline
```

Create your role and publish it to git. For example, you have a role that sets up /etc/motd, another that configures /etc/issue. You would then create a ‘master’ role which references the other roles using the following syntax in requirements.yml:

```
- src: git+ssh://git@<company_git_server>/<rolerepo>.git
  scm: git
```

## Define Variables when conditions are met

Link: [Ansible: Conditionally define variables in vars file if a certain condition is met](https://serverfault.com/questions/907164/ansible-conditionally-define-variables-in-vars-file-if-a-certain-condition-is-m)

The example listed suggests you can use the following to set variables according to the role/function of a server:

```
- include_vars: test_environment_vars.yml
  when: global_platform == "test"

- include_vars: staging_environment_vars.yml
  when: global_platform == "staging"

- include_vars: prod_environment_vars.yml
  when: 
    - global_platform != "test" 
    - global_platform != "staging" 
```

You can use this approach for maintaining other variables. For example, you have some sysctl parameters that should be applied for different versions of database software, such as Oracle.

## Pass Extra Variables to playbooks

There will be some tasks you will want to be run by support staff in AWX or Ansible Tower. For example, setting the root password on all servers. AWX gives you a controlled, auditable, repeatable way of achieving this. Other tasks will be run by experienced sysadmins that want to use the command line. In an ideal world, you want to create code that can run on the CLI and Ansible Tower/AWX.

Link: [Ansible – Pass extra variables to Playbook](https://ttl255.com/ansible-pass-extra-variables-to-playbook/). You can choose to store your variable in AWX/Tower but need to simulate them on the command line. The following code can help achieve this:

```
ansible-playbook extra_var_json.yml -e '{"my_string": "JSON with spaces", "my_float": 1.618, "my_list": ["HGTTG", 42]}'
```

## View only Ansible Failures

Link: [Only see failures](https://www.reddit.com/r/ansible/comments/d3tmsq/only_see_failures/). When first starting out, you will want to ensure that your Ansible control host, Tower or AWX instance can manage all your servers. If the majority of servers are in a good state, and you only want to report on failures, use the ANSIBLE_DISPLAY_OK_HOSTS and ANSIBLE_DISPLAY_SKIPPED_HOSTS environment variables or **display_ok_hosts** and **display_skipped_hosts** in your ansible ini file. Here’s a useful example on the command line:

```
ANSIBLE_DISPLAY_OK_HOSTS=false ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ansible all -m ping
```

There is also the –one-line (-o) flag. This makes it easier to use shell tools such as grep, sed and awk to manipulate the results:

```
ansible --one-line ..... | grep -v SUCCESS
```

## Running Ansible against a host that is not in the inventory

Link: [Ansible Tower Question](https://www.reddit.com/r/ansible/comments/d2b3ve/ansible_tower_question/). This is quite common in my environment, especially when provisioning new servers that don’t (yet) appear in our external inventory sources such as Red Hat Satellite, Service Now, etc and/or we don’t want to call the external inventory source because of the amount of time it takes to run. A nice solution is to create or update an inventory when a job is launched. For example:

```
- name: create inventory, add hosts to it, then launch my playbook against those hosts
  hosts: localhost
  vars:
    your_host: mywebhost1.example.com
    app_name: Example
  tasks:
  - name: Create the inventory
    uri:
      url: https://mytowerhost/api/v2/inventories/
      method: POST
      body_format: json
      headers:
        Authorization: Bearer XXXXXXXXXXXXXXXXXXXXXXXXXX
      body:
        name: "{{ app_name }}"
        organization: 1
      return_content: yes
      status_code: [201]
    ignore_errors: true ##(incase inventory already exists
    register: tower_inv

   - name: Add hosts
     uri:
       url: https://mytowerhost/api/v2/inventories/{{ tower_inv.json.id }}/hosts/
       method: POST
       body_format: json
       headers:
         Authorization: Bearer XXXXXXXXXXXXXXXXXXXXXXXXXX
       body:
         name: "{{ your_host }}"
         variables:
           ansible_host: "{{ your_host }}"
           ansible_user: yourRootUser
           ansible_pass: yourRootPass ##etc, etc..
       status_code: [201]

    - name: Call your playbook with the hosts/inventory you just created
      uri:              ##replace 20 with id of the the job template you want
        url: https://mytowerhost/api/v2/job_templates/20/launch 
        method: POST
        body_format: json
        headers:
          Authorization: Bearer XXXXXXXXXXXXXXXXXXXXXXXXXX
        body:
          inventory: "{{ tower_inv.json.id }}"
```

## Using pipefail with shell module in Ansible

Link: [Using pipefail with shell module in Ansible](https://blog.christophersmart.com/2019/09/28/using-pipefail-with-shell-module-in-ansible/). One of the great things about Ansible is that it’s easy to get started. One of the first things users will do is run ‘ad-hoc’ commands on hosts, and pretty quickly they will try to pipe one command into another. Use the ‘set -o pipefail’ option in your shell commands to ensure that failures are correctly reported:

```
ansible myhost -i hostfile -m shell -a 'set -o pipefail && /path/to/nonexistant/script | wc -l'
```

The return code from this host will now return FAILED.

## Combine Two Lists

Link: [How to combine two lists](https://serverfault.com/questions/737007/how-to-combine-two-lists). This will be useful if you have two sets of variables which you need to ‘merge’ together. For example, you have parameters that go to all servers and a number of bespoke ones that need to be combined with them. Example, common sysctl parameters and then some custom ones. The ‘union’ function can be helpful here:

```
all_settings="{{ foo|map(attribute='settings')|union(bar|map(attribute='settings')) }}"
```

## Ansible Lint / Yamllint

Link: [Linting your Ansible Playbooks and make a Continuous Integration (CI) solution](https://medium.com/faun/linting-your-ansible-playbooks-and-make-a-continuous-integration-ci-solution-bcf8b4ea4c03). ‘[ansible-lint](https://github.com/ansible/ansible-lint)‘ and ‘[yamllint](https://github.com/adrienverge/yamllint)‘ are useful tools for making sure that your yaml code and playbooks conform to best practice and do what you expect them to do. For example, in a complex YAML file, have you accidentally defined the same key-value pair twice? Which one will take precedence? These tools can help deal with this. One solution is to run these tools prior to them being uploaded into source code repositories, the other is to run tests when commits are made.

## Satellite 6 / Callback Integration

Link: [Use Satellite 6 as an inventory source](https://www.ansible.com/blog/use-satellite-6-as-an-inventory-source-in-ansible-tower).  
Link: [Connecting Satellite 6 and Ansible Tower](http://100things.wzzrd.com/2017/03/30/Connecting-Satellite-6-and-Ansible-Tower.html).

Linking your AWX/Tower server to Red Hat Satellite 6 is a great way to manage your environment. Callbacks are a nice way to running a Playbook as part of the provisioning process. Even if your servers are not provisioned by Satellite, you can still call playbook from AWX/Tower at first boot via systemd unit file or custom script. (See the related in this post about adding a host to an inventory if it does not already exist). A callback script to setup a systemd unit could look as follows and would typically be included in the %post section of a kickstart file:

```
#!/bin/bash
cat > /etc/systemd/system/ansible-callback.service << EOF
[Unit]
Description=Provisioning callback to Ansible
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/curl -k -s --data "host_config_key=XYZ" https://awx.example.com/api/v1/job_templates/NN/callback/
ExecStartPost=/usr/bin/systemctl disable ansible-callback

[Install]
WantedBy=multi-user.target
EOF

# Runs during first boot, removes itself
/usr/bin/systemctl enable ansible-callback
```

Thanks to [http://100things.wzzrd.com/2017/03/30/Connecting-Satellite-6-and-Ansible-Tower.html](http://100things.wzzrd.com/2017/03/30/Connecting-Satellite-6-and-Ansible-Tower.html) for this idea.

## Async Actions for long running tasks

It may be the case that you have playbooks which take a long time to run. In my case, we run some scripts on our Satellite server to manipulate content views and synchronise Red Hat Satellite capsule servers. Due to bandwidth limitations the synchronisation can take many hours. The playbooks look like this:

```
 - name: Manipulate RHEL 6 Content View biz unit 1
   command: /path/to/script.sh rhel6-biz-unit-1
   register: output
   tags: rhel6

- debug:
    msg: "{{output.stdout_lines}}"
  tags: rhel6

 - name: Manipulate RHEL 7 Content View biz unit 1
   command: /path/to/script.sh rhel7-biz-unit-1
   register: output
   tags: rhel7

- debug:
    msg: "{{output.stdout_lines}}"
  tags: rhel7
```

When running under AWX/Tower, the script suddenly aborts exactly 1 hour into the job:

```
{
    "unreachable": true,
    "msg": "Failed to connect to the host via ssh: Shared connection to satellite.example.com closed.",
    "changed": false
}
```

Right at that time, [Adam Miller](https://twitter.com/TheMaxamillion) posted the following:

Sure enough, Async Actions were what I needed so I re-wrote the playbooks as follows:

```
 - name: Manipulate RHEL 6 Content View biz unit 1
   command: /path/to/script.sh rhel6-biz-unit-1
   register: output
   async: 14400
   tags: rhel6

- debug:
    msg: "{{output.stdout_lines}}"
  tags: rhel6

 - name: Manipulate RHEL 7 Content View biz unit 1
   command: /path/to/script.sh rhel7-biz-unit-1
   register: output
   async: 14400
   tags: rhel7

- debug:
    msg: "{{output.stdout_lines}}"
  tags: rhel7
```

AWX/Tower is now to process these long running jobs successfully. Take a look at the links in Adam’s post for further details on asynchronous actions.

## Securing AWX

At the London Red Hat forum in 2019 someone asked what is the best practice for securing AWX/Ansible Tower itself? Given that AWX has the access rights to connect to most of your servers, keeping it secure becomes an important topic. Some suggestions:

-   Always pull code from your (secured) Git repository. Although it is possible to store code locally on an AWX server, if compromised by bad file permissions someone could manipulate a task to do something malicious. Don’t let that happen, set your projects to always pull from Git on launch.
-   Along with the point above, ensure your Git repository is secured – for example limit user access, use read-only deployment keys, enable two factor authentication, etc.
-   Use the option ‘delete on update’ to ensure the local repository in its entirety is removed prior to performing an update from your source code repository.
-   Authenticate users with an identity source such as LDAP. If a user leaves or changes role, a check can be made to make sure they are part of an LDAP group and prevent access if that requirement is not met. Local AWX users are a no-go.
-   Limit access on the server itself only to those that require it.
-   Use standard O/S hardening on the AWX/Tower server – configure a local firewall, enable SELinux, configure Intrusion Detection, enforce strong authentication, beware of access via SSH authorized keys.
-   Audit. Regularly review logs for both access and job completion to ensure they meet the expectations for your environment – for example a sudden submission of ‘ad-hoc’ commands might be the sign of an attacker probing your servers.

## How are managed nodes counted in Red Hat Ansible Automation Platform?

If you want the benefits of support, migrating from Ansible AWX to Red Hat Ansible Automation Platform probably makes a lot of sense. However, in a large enterprise you might want to create organisations within Ansible Tower – for example an Operations group that perhaps deploys patches to servers, an Infrastructure group that performs admin on the servers, an Application group that manages the applications that runs on the servers. Each team (Organisation) will have their own inventories, credentials and playbooks. Does that mean that Ansible Tower requires many more licenses to manage these subscriptions? [How are “managed nodes” defined as part of the Red Hat Ansible Automation Platform offering](https://access.redhat.com/articles/3331481) suggests that this is not the case:

> Ansible may manage nodes from multiple different access paths based on the above use cases. In the event that this results in multiple host identifiers for a given host in Ansible inventory, it does not increase the required host entitlements for the customer. That is, a managed host is not “charged” multiple times based upon multiple automation actions or methods targeting that host.
> 
> https://access.redhat.com/articles/3331481

## Visualise and make use of Ansible facts

[visansible](https://github.com/multigcs/visansible) is a very handy tool if you want to visually map out your environment. To get started, make use of the [setup](https://docs.ansible.com/ansible/latest/modules/setup_module.html) module to query the facts from your environment.

```
# Display facts from all hosts and store them indexed by I(hostname) at C(/tmp/facts).
# ansible all -m setup --tree /tmp/facts
```

The output in /tmp/facts can be useful for all sorts of data processing and analysis. However, combine it with visansible and you can visualize the findings. Another useful tool for the facts is [ansible-cmdb](https://ansible-cmdb.readthedocs.io/en/latest/) which can generate a dynamic HTML page with useful information you might get from a traditional Configuration Management Database (CMDB).
