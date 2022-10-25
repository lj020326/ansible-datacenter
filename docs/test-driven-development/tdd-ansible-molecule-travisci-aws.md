
# Continuous cloud infrastructure with Ansible, Molecule & TravisCI on AWS

By implementing Test-driven development and Continuous Integration for infrastructure code with Ansible and Molecule, we’ve done a huge step towards the right direction. But we should not exclude our cloud infrastructure! Here’s a guide on how to use Molecule with AWS EC2, naturally triggered by TravisCI.

## Ansible & Molecule – blog series

Part 1: [Test-driven infrastructure development with Ansible & Molecule](./test-driven-infrastructure-ansible-molecule-and-testinfra.md)  
Part 2: [Continuous Infrastructure with Ansible, Molecule & TravisCI](tdd-continuous-infrastructure-ansible-molecule-travisci.md)  
Part 3: Continuous cloud infrastructure with Ansible, Molecule & TravisCI on AWS

## What about the cloud?

In the course of this blog post series, we have come quite far. We’re now able to write tests for our infrastructure code using [Molecule](https://molecule.readthedocs.io/en/latest/) & [Testinfra](https://testinfra.readthedocs.io/en/latest/) . And these tests are executed by our CI platform every time we commit code or the cron job automatically pulls the trigger. **So we gained a lot more trust in our code.** And at the same time, our Ansible role can be executed by Molecule on multiple infrastructure providers like Docker and Vagrant. We just need to leverage the power of Molecule’s multi-scenario approach.

But wait! Didn’t they say **Molecule was also able to use cloud infrastructure as well?** Isn’t Molecule built on top of Ansible to be able to use possibly every infrastructure? It’s pretty cool to use local infrastructure – be it on our laptop or on TravisCI. But what about using a cloud infrastructure like [Amazon Web Services (AWS)](https://aws.amazon.com/) ? It would be great to have our Ansible roles automatically tested against that also. And it would also enable us to leave the ‘hello world’ examples and **test the Ansible roles that need to invoke multiple instances at the same time,** as required in projects like [kubernetes-the-ansible-way](https://github.com/jonashackt/kubernetes-the-ansible-way) . So we should have a look on how to use Molecule with AWS and continuously run every test with a CI platform like TravisCI.

## AWS EC2 as Molecule’s infrastructure provider

The list of [Molecule’s supported cloud infrastructure providers](https://molecule.readthedocs.io/en/latest/configuration.html#driver) is quite long. And it should be, since Molecule is built right on top of Ansible. If you want to get a feeling of how comprehensive Ansible’s cloud modules are, just take a look at the docs. I am impressed every time I look into them, since **this list is growing rapidly with every Ansible release.**

![project overview](./img/dxUa8GF1TN2BC84y7kih.png)

logo sources: [Molecule logo](https://molecule.readthedocs.io/en/latest/) , [Vagrant logo](https://www.vagrantup.com/) , [VirtualBox logo](https://www.virtualbox.org/) , [Ansible logo](https://www.ansible.com/) , [Docker logo](https://www.docker.com/) , [Testinfra logo](https://testinfra.readthedocs.io/en/latest/) , [pytest logo](https://docs.pytest.org/en/latest/) , [Ubuntu logo](https://design.ubuntu.com/brand/ubuntu-logo/)

This blog series’ [example project on GitHub](https://github.com/jonashackt/molecule-ansible-docker-aws) will be enhanced here again so every step is fully comprehensible. As we already introduced Molecule’s multi-scenario approach in [the second article](https://blog.codecentric.de/en/2018/12/continuous-infrastructure-ansible-molecule-travisci/) , it should be no big deal to integrate [Molecule’s AWS EC2 driver](https://molecule.readthedocs.io/en/latest/configuration.html#ec2) into a new scenario inside the existing example project. Assuming that you followed all the other steps mentioned in the previous posts, the only prerequisite to using Molecule’s AWS EC2 driver is to install the [boto Python packages](https://pypi.org/project/boto/) . They will provide interfaces to Amazon Web Services for Molecule, which itself uses [Ansible’s ec2 module](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_module.html) to interact with AWS. Simply install the boto packages via the Python package manager pip:

## Configure Molecule to use AWS EC2

As [the example project](https://github.com/jonashackt/molecule-ansible-docker-aws) already consists of two scenarios – `default` for Docker and `vagrant-ubuntu` for the Vagrant infrastructure provider – we simply need to leverage Molecule’s `molecule init scenario` command, which doesn’t initialize a full-blown new Ansible role like `molecule init role`. **It just integrates a new scenario inside a multi-scenario project.** Let’s call our new scenario `aws-ec2-ubuntu`. Simply put `cd` into the Ansible role’s root directory `molecule-ansible-docker-aws/docker` and run:

```
molecule init scenario --driver-name ec2 --role-name docker --scenario-name aws-ec2-ubuntu

```

This should create a new directory `aws-ec2-ubuntu` inside the `docker/molecule` folder. We’ll integrate the results into our multi-scenario project in a second. First let’s have a look at what the project structure now looks like:

![project structure](./img/qDQTwYOhSSSbbj4ATFhW.png)

Compared to the Docker or Vagrant scenarios, Molecule generated a few files more this time. Next to the already well-known `molecule.yml` there are also `create.yml` and `destroy.yml` playbooks. The `prepare.yml` playbook and the documentation file `INSTALL.rst` are again nothing new to us. So let’s dig into the generated molecule.yml first:

```
scenario:
  name: ec2
 
driver:
  name: ec2
platforms:
  - name: instance
    image: ami-a5b196c0
    instance_type: t2.micro
    vpc_subnet_id: subnet-6456fd1f
 
provisioner:
  name: ansible
  lint:
    name: ansible-lint
    enabled: false
  playbooks:
    converge: ../playbook.yml
 
lint:
  name: yamllint
  enabled: false
 
verifier:
  name: testinfra
  directory: ../tests/
  env:
    # get rid of the DeprecationWarning messages of third-party libs,
    # see https://docs.pytest.org/en/latest/warnings.html#deprecationwarning-and-pendingdeprecationwarning
    PYTHONWARNINGS: "ignore:.*U.*mode is deprecated:DeprecationWarning"
  lint:
    name: flake8
  options:
    # show which tests where executed in test output
    v: 1

```

Compared to the other scenarios, there’s only one main difference here: the `driver.name` configuration uses `ec2` and the `platforms` key contains some AWS EC2-specific parameters. The platform is already pre-configured with a concrete _Amazon Machine Image (AMI)_ and `instance_type` alongside a specific `vpc_subnet_id`. For now I just tuned the instance name to `aws-ec2-ubuntu`, like we already did in our Docker and Vagrant scenarios. To keep the Molecule scenario name and the infrastructure instance names in sync is just a **an assistance for us to be able to find out what part we are looking at right now.**

As already mentioned, we have to tune some parts inside the `molecule.yml` to fully match our project’s multi-scenario setup. First of all, the configuration parameter `provisioner.playbook.converge` needs to be configured in a way that Molecule is able to find the single `playbook.yml`. Also the `verifier` section has to be enhanced to gain all the described advantages like supressed deprecation warnings and the better test result overview.

## Having a glance at the create.yml

The command `molecule init scenario` also generated the `create.yml`. As this is a generated file, we don’t have to maintain it. But as a curious person who already loves Ansible, I couldn’t resist taking a look. At first it looks rather stunning – especially to the ones new to AWS. Let’s have a look at the create.yml (I’ve shortened it a bit):

```
- name: Create
  hosts: localhost
  connection: local
  gather_facts: false
  no_log: "{{ not (lookup('env', 'MOLECULE_DEBUG') | bool or molecule_yml.provisioner.log|default(false) | bool) }}"
  vars:
    ssh_user: ubuntu
    ssh_port: 22
 
    security_group_name: molecule
    security_group_description: Security group for testing Molecule
    security_group_rules:
      - proto: tcp
        from_port: "{{ ssh_port }}"
        to_port: "{{ ssh_port }}"
        cidr_ip: '0.0.0.0/0'
      - proto: icmp
        from_port: 8
        to_port: -1
        cidr_ip: '0.0.0.0/0'
    security_group_rules_egress:
      - proto: -1
        from_port: 0
        to_port: 0
        cidr_ip: '0.0.0.0/0'
 
    keypair_name: molecule_key
    keypair_path: "{{ lookup('env', 'MOLECULE_EPHEMERAL_DIRECTORY') }}/ssh_key"
  tasks:
    - name: Create security group
      ec2_group:
        name: "{{ security_group_name }}"
        description: "{{ security_group_name }}"
        rules: "{{ security_group_rules }}"
        rules_egress: "{{ security_group_rules_egress }}"
 
    ...
 
    - name: Create keypair
      ec2_key:
        name: "{{ keypair_name }}"
      register: keypair
 
    - name: Persist the keypair
      copy:
        dest: "{{ keypair_path }}"
        content: "{{ keypair.key.private_key }}"
        mode: 0600
      when: keypair.changed
 
    - name: Create molecule instance(s)
      ec2:
        key_name: "{{ keypair_name }}"
        image: "{{ item.image }}"
        instance_type: "{{ item.instance_type }}"
        vpc_subnet_id: "{{ item.vpc_subnet_id }}"
        group: "{{ security_group_name }}"
        instance_tags:
          instance: "{{ item.name }}"
        wait: true
        assign_public_ip: true
        exact_count: 1
        count_tag:
          instance: "{{ item.name }}"
      register: server
      with_items: "{{ molecule_yml.platforms }}"
      async: 7200
      poll: 0
 
    - name: Wait for instance(s) creation to complete
      async_status:
        jid: "{{ item.ansible_job_id }}"
      register: ec2_jobs
      until: ec2_jobs.finished
      retries: 300
      with_items: "{{ server.results }}"

```

Skimming the code, we notice the usage of [Ansible’s ec2\_group module](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_group_module.html) . It is used to maintain _AWS EC2 security groups_. Using the parameters `rules` and `rules_egress`, it configures appropriate firewall inbound and outbound rules for our Molecule EC2 instance.

After that, [Ansible’s ec2\_key module](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_key_module.html) is used to create a new EC2 key pair and store it locally if none exists on your local machine already. Now the [ec2 module](https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_module.html) takes over, which is able to **create or terminate AWS EC2 instances without any hassle with the AWS GUI.** Waiting for the EC2 instance to come up, the `create.yml` playbook uses the [async\_status module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/async_status_module.html) on the pre-registered variable `server.results` from the `ec2` module.

The following Ansible modules are solely used to create an inline Ansible inventory, which is finally used to connect into the EC2 instance via SSH. The also generated `destroy.yml` playbook is just the opposite to the `create.yml` playbook and tears the created EC2 instance down.

## Install and configure AWS CLI

Now let’s focus on our target again: using _AWS EC2_ as an infrastructure provider for Molecule. **We want to be able to run our tests again!** So what’s left to do? In order to be able to successfully run our Molecule tests with AWS EC2, we need to have the [AWS CLI installed](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) . Like Molecule or Ansible, we can do this via [Python package manager pip](https://pypi.org/project/pip/) :

Having done that, we should check if the AWS CLI was successfully installed. The `aws --version` command should print out something like the following:

```
$ aws --version
aws-cli/1.16.80 Python/3.7.2 Darwin/18.2.0 botocore/1.12.70

```

In order to configure the AWS CLI to use the correct credentials and AWS region, we need to take a look at [the AWS docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration) . According to them, the fastest way to accomplish a correct configuration is to run `aws configure`:

```
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: eu-central-1
Default output format [None]: json

```

Insert your AWS access key and secret alongside your desired AWS region. For me, this is `eu-central-1`.

## Configure region & VPC subnet id

> Using Molecule’s AWS EC2 has two configuration inconsistencies right now: the configuration of the AWS region and the VPC subnet id.

Every configuration parameter used for Molecule’s AWS connectivity is generated correctly by the command `molecule init --driver-name ec2`. The credentials are picked up correctly from the file `~/.aws/credentials`, where AWS CLI stores them. **Except** the `region` configuration, which can be obtained from `~/.aws/config`. Running a Molecule test without the additional setting of the AWS region as an environment variable currently results [in this documented error](https://github.com/ansible-community/molecule/issues/1570) :

```
"msg": "Either region or ec2_url must be specified",

```

To fix this, we need to **set the region as environment variable before running our Molecule tests against EC2:**

```
export EC2_REGION=eu-central-1

```

And there’s another thing left to do: we need to configure the correct `vpc_subnet_id` inside our `molecule.yml`. If we forget to do so, we’ll get errors like this:

```
    "    raise self.ResponseError(response.status, response.reason, body)",
    "boto.exception.EC2ResponseError: EC2ResponseError: 400 Bad Request",
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
    "<Response><Errors><Error><Code>InvalidSubnetID.NotFound</Code><Message>The subnet ID 'subnet-6456fd1f' does not exist</Message></Error></Errors><RequestID>1c971ba2-0d86-4335-9445-d989e988afce</RequestID></Response>"
]

```

Therefore we have to **figure out the correct VPC subnet ID of our region.** For this, we can simply use AWS CLI with `aws ec2 describe-subnets` to find the correct ID inside the field `Subnets.SubnetId`:

```
$ aws ec2 describe-subnets
 
{
    "Subnets": [
        {
            "AvailabilityZone": "eu-central-1b",
            "AvailabilityZoneId": "euc1-az3",
            ...
            "SubnetId": "subnet-a2efa1d9",
            ...
        },
        {
            "AvailabilityZone": "eu-central-1c",
            ...
        },
        {
            "AvailabilityZone": "eu-central-1a",
            ...
        }
    ]
}

```

Having the correct ID, we can head over to our molecule.yml and edit the `vpc_subnet_id` so it contains the right value:

```
scenario:
  name: aws-ec2-ubuntu
 
driver:
  name: ec2
platforms:
  - name: aws-ec2-ubuntu
    image: ami-a5b196c0
    instance_type: t2.micro
    vpc_subnet_id: subnet-a2efa1d9
...

```

## Choosing an AMI with Ubuntu 18.04

[As stated on askubuntu.com](https://askubuntu.com/a/1031156/451114) , Amazon maintains an “official” Ubuntu 18.04 Amazon Machine Image (AMI). **But this one isn’t available under the free tier right now.** As this official image is just the same as the one from _Canonical_, we can easily switch to this alternative – since this is allowed to be used with the free tier.

Every publicly available _Canonical AMI_ could be found with the [ubuntu Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/) . Just fill in your region like `eu-central-1` together with the desired Ubuntu version and the site should filter all available AMI images in this region:

![ubuntu ami locator](./img/ZAVdg1mCTuGd0ult5Xk5.png)

As you may notice, **there are several possible AMIs left.** In our case, we need to choose the AMI ID with the _Instance Type_ `hvm:ebs-ssd`. This means our EC2 instance will use Amazon Elastic Block Storage memory (EBS) instead of instance storage. Only the EBS instance type is eligible for free tier usage right now. In my AWS region `eu-central-1` the correct AMI ID for Ubuntu 18.04 is `ami-080d06f90eb293a27`. Pick the AMI ID that corresponds to your region and then configure it inside the `platforms.image` paramter in the molecule.yml:

```
scenario:
  name: aws-ec2-ubuntu
 
driver:
  name: ec2
platforms:
  - name: aws-ec2-ubuntu
    image: ami-080d06f90eb293a27
    instance_type: t2.micro
    vpc_subnet_id: subnet-a2efa1d9
...

```

## Creating a EC2 instance with Molecule

**Now we should have everything prepared to start running Molecule tests on AWS EC2.** To create the infrastructure needed to run our tests on, all we have to do is invoke Molecule’s `create` step. Therefore, we run the following command (including the `--debug` flag so that we are able to see what’s going on):

```
molecule --debug create --scenario-name aws-ec2-ubuntu

```

In the meantime we can look at our Ansible EC2 management console at [eu-central-1.console.aws.amazon.com/ec2/v2/](https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1) . After giving the `molecule create` command a go, we should see our first Molecule EC2 instance starting up:

![aws ec2 management console instance startup](./img/9NYvoiyVQGuNASNvt0SX.png)

If everything went fine in Molecule’s `create` phase, the EC2 management console should show the running EC2 instance:

![aws ec2 management console instance running](./img/zEvbB9ktRwmcI4Q2IxJQ.png)

## Run a first test on EC2 with Molecule

If the AWS EC2 instance was created successfully, we can move on to Molecule’s `converge` phase. This should run our implemented Ansible role against the initialized EC2 instance. Therefore we need to execute:

```
molecule converge --scenario-name aws-ec2-ubuntu

```

If that worked out fine, **we’re finally where we wanted to be in the first place!** We’re now able to run our Molecule tests in the `verify` phase. In order to invoke this last step, we have to run:

```
molecule verify --scenario-name aws-ec2-ubuntu

```

This should successfully execute our Testinfra test suite described in docker/molecule/tests/test\_docker.py onto our EC2 instance. If everything went fine, it should output something like:

![aws molecule verify success](./img/HnJ5EGgQQjicNJlH77Je.png)

## Cleaning up

Finally it’s time to terminate our EC2 instance. In order to achieve this, all we need to do is run a `molecule destroy` command that will tear down our EC2 instance:

```
molecule --debug destroy --scenario-name aws-ec2-ubuntu

```

Again we can take a look at our AWS EC2 management console:

![aws ec2 management console instance terminated](./img/mB4vP3jxQbKrXmqz9bfU.png)

Our EC2 instance should have reached the state `terminated`. This state is similar to the `stopped` state. The only difference is the additional step of also removing the attached EBS storage (see the [AWS EC2 Instance Lifecycle chart](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html) for more info).

Here’s also a full asciinema cast containing all mentioned steps:

[![](https://media.graphassets.com/lIVzBv2SXidXl4vyMBZF)](https://asciinema.org/a/220434)

For me, the ultimate goal of this whole journey with Molecule was to be able to have TravisCI create cloud environments to execute and test Ansible roles on them. This is needed for _“beyond-hello-world”_ projects like [kubernetes-the-ansible-way](https://github.com/jonashackt/kubernetes-the-ansible-way) .

To achieve this, we need to bring all our latest learnings together:

> We’ll use Molecule to develop and test Ansible roles, leveraging cloud infrastructure providers like AWS and executing everything automatically with TravisCI – triggered by commits or cron jobs.

![molecule travis aws overview](./img/DjMR1GG6TESosV923H0o.png)

logo sources: [Molecule logo](https://molecule.readthedocs.io/en/latest/) , [Vagrant logo](https://www.vagrantup.com/) , [VirtualBox logo](https://www.virtualbox.org/) , [Ansible logo](https://www.ansible.com/) , [Docker logo](https://www.docker.com/) , [Testinfra logo](https://testinfra.readthedocs.io/en/latest/) , [pytest logo](https://docs.pytest.org/en/latest/) , [Ubuntu logo](https://design.ubuntu.com/brand/ubuntu-logo/) , [TravisCI logo](https://travis-ci.com/logo) , [GitHub logo](https://github.com/logos)

**So let’s do it!** We need to configure TravisCI by enhancing its configuration file [.travis.yml](https://github.com/jonashackt/molecule-ansible-docker-aws/blob/travis/.travis.yml) :

```
sudo: required
language: python
 
env:
- EC2_REGION=eu-central-1
 
services:
- docker
 
install:
- pip install molecule
- pip install docker-py
 
# install AWS related packages
- pip install boto boto3
- pip install --upgrade awscli
 
# configure AWS CLI
- aws configure set aws_access_key_id $AWS_ACCESS_KEY
- aws configure set aws_secret_access_key $AWS_SECRET_KEY
- aws configure set default.region $DEPLOYMENT_REGION
# show AWS CLI config
- aws configure list
 
script:
- cd docker
 
# Molecule Testing Travis-locally with Docker
- molecule test
 
# Molecule Testing on AWS EC2
- molecule create --scenario-name aws-ec2-ubuntu
- molecule converge --scenario-name aws-ec2-ubuntu
- molecule verify --scenario-name aws-ec2-ubuntu
- molecule destroy --scenario-name aws-ec2-ubuntu

```

First we need to **set the region as an appropriate environment variable** inside the `env` parameter. Inside the `install` section, we need to make sure that the same **Python package additions are present** that we already installed locally. This includes `boto/boto3` and `awscli`.

After that, we need to **configure the AWS CLI** to use the correct credentials and AWS region. This can be achieved by using the `aws configure set` command. Heading over to the **settings tab of our TravisCI project**, we need to correctly insert the three environment variables `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, and `DEPLOYMENT_REGION`:

![travisci aws settings env variables](./img/TN6TGqtsTpqKlPZ7VCzo.png)

The last part is to **add the molecule commands** to the `script` section of the `.travis.yml`.

## Fixing current problems with boto on Travis

Sadly there’s [a flaw while using the AWS connectivity library boto on TravisCI right now](https://github.com/boto/boto/issues/3717) . This results in errors like:

```
        ...
            "  File \"/tmp/ansible_ec2_payload_y3lfWH/__main__.py\", line 552, in <module>", 
            "  File \"/home/travis/virtualenv/python2.7.14/lib/python2.7/site-packages/boto/__init__.py\", line 1216, in <module>", 
            "    boto.plugin.load_plugins(config)", 
            "AttributeError: 'module' object has no attribute 'plugin'"
        ]
    }
 
    PLAY RECAP *********************************************************************
    localhost                  : ok=6    changed=4    unreachable=0    failed=1   
 
ERROR: 
The command "molecule --debug create --scenario-name aws-ec2-ubuntu" exited with 2.

```

To fix this, there are **two changes needed** inside our [.travis.yml](https://github.com/jonashackt/molecule-ansible-docker-aws/blob/travis/.travis.yml) . We need to set sudo to `false` and use the environment variable `BOTO_CONFIG=/dev/null`:

```
sudo: false
language: python
 
env:
- EC2_REGION=eu-central-1 BOTO_CONFIG="/dev/null"
...

```

> Remember to add the `BOTO_CONFIG` environment variable into the exact same line as the already existing variable `EC2_REGION`. Otherwise [Travis starts multiple builds](https://docs.travis-ci.com/user/environment-variables/#defining-multiple-variables-per-item) with only one variable set to each build.

Now head over to Travis and check out the log. If everything went fine, the output should look green and somehow like this:

![travisci successfull molecule aws run](./img/rSJ8VlbBSm1pcrd5LS6V.png)

## Continuous cloud infrastructure rocks!

Throughout the post we saw how easy it is to use a cloud infrastructure provider like AWS EC2 together with Ansible & Molecule. The boilerplate playbooks are generated by Molecule for us, enabling us at the same time to learn how to use Ansible to manage our cloud environments thanks to the enormous cloud module list. **Now we’re able to develop and test our Ansible roles against multiple (cloud) infrastructures at the same time.** This gives us much more trust in our infrastructure code. We can verify any time if our code is able to run on every infrastructure we can think of. Darn cool. 🙂

And doing the **Molecule tests on our CI platform** to verify our code on multiple infrastructures automatically takes the cake! This post outlined comprehensibly how to configure TravisCI to execute Molecule tests on AWS EC2 instances – starting, initializing and terminating the infrastructure as it is needed throughout the verification. **The safety net has become thicker again.** All this should enable us to finally test much more complex Ansible roles automatically with Molecule!

As always, there are things left to do. We can take a look at other cloud providers as well. Or we can dive into the zoo of tools of a certain provider. Just pick one of those tools and you’ll be able to write the next post! We also have some Molecule verifiers left and maybe we’ll finally see how to test [a full Kubernetes setup](https://github.com/jonashackt/kubernetes-the-ansible-way) . Stay tuned!