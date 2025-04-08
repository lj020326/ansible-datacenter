
# Ansible Collections: Role Tests with Molecule

As many of you know or are finding out, Ansible is moving to Collections. But what does that mean? Well, it’s been a long time waiting but Collections provide a way to namespace modules, roles, and playbooks that can all be combined in a single package for you to consume. It also allows businesses, partners, and contributors to update modules without adhering to the Ansible core release cycle. So, if AWS updates their API, then the modules that go with those will be instantly accessible, or at least faster than we used to wait for core releases to get those modules. But what does this mean for roles?

As many of us our finding out we are needing to move our roles to the collection design. However, now we need to figure out how to test them with the new design and using the Collection Namespaces aka FQCN (Fully Qualified Collection Name) So what we used to write

```yaml
---
- hosts: localhost
  connection: local
  vars:
    some_var: var_value1
  tasks:
    - include_role:
        name: dettonville.rolename
      vars:
        param: some_var
```

Will now end up something like this

```yaml
---
- hosts: localhost
  connection: local
  vars:
    some_var: var_value1
  tasks:
    - include_role:
        name: dettonville.collection.rolename
      vars: param: some_var

```

We also are going to have a new folder structure using ansible_collections/namespace/collection_name

Luckily the molecule team and all of its contributors ensured that collections are recognized and supported. And I will cover how we can test this with GitHub Actions (which happen to also be the preferred way at this moment to test your collections on the official Ansible-Collections Github [https://github.com/ansible-collections](https://github.com/ansible-collections).

Since Travis-CI can’t do Matrix workflows with multiple user-provided axes, I decided, let’s just treat this as a single playbook. So the only option I found was like this.

```yaml
---
- name: Converge
  hosts: all
  pre_tasks:
    - name: Update package cache
      package: update_cache=yes
      changed_when: false
      register: task_result
      until: task_result is success
      retries: 10
      delay: 2
    - name: create containerd folder
      file:
        path: /etc/systemd/system/containerd.service.d
        state: directory
      when: ansible_service_mgr == "systemd"
    - name: override file for containerd
      copy:
        src: files/override.conf
        dest: /etc/systemd/system/containerd.service.d/override.conf
      when: ansible_service_mgr == "systemd"
  roles:
    - role: dettonville.system.selinux
      when: ansible_os_family == "RedHat"
    - role: dettonville.system.chrony
    - role: dettonville.system.epel
      when: ansible_os_family == "RedHat"
    - role: dettonville.system.logrotate
    - role: dettonville.system.remi_repo
      when: ansible_os_family == "RedHat"
```

As you see, in this format I had to make sure RedHat specific roles don’t get run on non-RedHat systems. But then this tests every role together and doesn’t easily allow me to scale to even more operating systems.  It will get long, and crazy with lots of when statements, and each time you add a role, you’ll have to edit this one and ensure the environment configuration is correct for all of the roles. It was at this point I realized maybe I should move away from Travis-CI, and also was encouraged to by the Ansible team. Gundalow and others recommended moving to GitHub Actions which are the preferred method now in the community. So I explored that option.

I also at this time decided to move away from the monolithic “default” scenario and instead divide scenarios based on roles. This is what I moved to.

```output
molecule
├── chrony
│   ├── Dockerfile.j2
│   ├── converge.yml
│   ├── files
│   │   └── override.conf
│   ├── molecule.yml
│   ├── tests
│   │   └── test_default.py
│   └── verify.yml
├── default
│   ├── Dockerfile.j2
│   ├── converge.yml
│   ├── files
│   │   └── override.conf
│   ├── molecule.yml
│   ├── tests
│   │   └── test_default.py
│   └── verify.yml
├── epel
│   ├── Dockerfile.j2
│   ├── converge.yml
│   ├── files
│   │   └── override.conf
│   ├── molecule.yml
│   ├── tests
│   │   └── test_default.py
│   └── verify.yml
├── logrotate
│   ├── Dockerfile.j2
│   ├── converge.yml
│   ├── files
│   │   └── override.conf
│   ├── molecule.yml
│   ├── tests
│   │   └── test_default.py
│   └── verify.yml
├── ntp
│   ├── Dockerfile.j2
│   ├── converge.yml
│   ├── files
│   │   └── override.conf
│   ├── molecule.yml
│   ├── tests
│   │   └── test_default.py
│   └── verify.yml
├── remi_repo
│   ├── Dockerfile.j2
│   ├── converge.yml
│   ├── files
│   │   └── override.conf
│   ├── molecule.yml
│   ├── tests
│   │   └── test_default.py
│   └── verify.yml
└── selinux
    ├── Dockerfile.j2
    ├── converge.yml
    ├── files
    │   └── override.conf
    ├── molecule.yml
    ├── tests
    │   └── test_default.py
    └── verify.yml
```

Now I was able to individually ensure each environment was correct. That includes each roles’ dependencies, etc, and that it doesn’t affect the others. It prevented any form of cross-contamination on testing, and what’s expected in requirements. This fixed one of my issues I had with testing, however, it did add a bit of complexity, but each one is almost identical so I could easily copy and paste one of these to help build tests for the new role.

When I started testing how I would do this using Github Actions I explored using Matrix workflows. That looked something like this (which was really awesome because I couldn’t do it in Travis-CI…I don’t know if I can go back to Travis-CI because apparently for me GitHub tests are much faster.)

```yaml
name: "dettonville.system.logrotate"
on: ["push", "pull_request"]
jobs:
  logrotate:
    runs-on: ubuntu-18.04
    env:
      PY_COLORS: 1 # allows molecule colors to be passed to GitHub Actions
      ANSIBLE_FORCE_COLOR: 1 # allows ansible colors to be passed to GitHub Actions
    strategy:
      fail-fast: true
      matrix:
        molecule_image_label:
          - distro: centos:7
            command: /usr/sbin/init # needed to ensure systemd is started on each to ensure proper service module testing
          - distro: centos:8
            command: /usr/sbin/init
          - distro: ubuntu:16.04
            command: /sbin/init
          - distro: ubuntu:18.04
            command: /lib/systemd/systemd
          - distro: ubuntu:20.04
            command: /lib/systemd/systemd
          - distro: debian:9
            command: /lib/systemd/systemd
        collection_role:
          - logrotate
          - chrony
          - epel
          - ntp
    steps:
      - name: Check out code
        uses: actions/checkout@v1
        with:
          path: ansible_collections/dettonville/system
 
      - name: Set up Python 3.8
        uses: actions/setup-python@v1
        with:
          python-version: 3.8
 
      - name: Install dependencies
        run: |
          sudo apt install docker
          python -m pip install --upgrade pip
          pip install molecule yamllint ansible-lint docker
 
      - name: Run role test
        run: >-
          molecule --version &&
          ansible --version &&
          MOLECULE_COMMAND=${{ matrix.molecule_image_label.command }}
          MOLECULE_IMAGE_LABEL=${{ matrix.molecule_image_label.distro }}
          molecule --debug test -s ${{ matrix.collection_role }}
```

However, here’s the issue with this...each commit no matter where it’s made will trigger the matrix to execute meaning 4 x 6 tests! Even though I modified 1 role. Also, EPEL doesn’t work on Ubuntu or Debian. So then I’d have to use a lot of these exclude  statements:

```yaml
jobs:
  logrotate:
    runs-on: ubuntu-18.04
    env:
      PY_COLORS: 1 # allows molecule colors to be passed to GitHub Actions
      ANSIBLE_FORCE_COLOR: 1 # allows ansible colors to be passed to GitHub Actions
    strategy:
      fail-fast: true
      matrix:
        molecule_image_label:
          - distro: centos:7
            command: /usr/sbin/init
          - distro: centos:8
            command: /usr/sbin/init
          - distro: ubuntu:16.04
            command: /sbin/init
          - distro: ubuntu:18.04
            command: /lib/systemd/systemd
          - distro: ubuntu:20.04
            command: /lib/systemd/systemd
          - distro: debian:9
            command: /lib/systemd/systemd
        collection_role:
          - logrotate
          - chrony
          - epel
          - ntp
        exclude:
          - {"molecule_image_label": {"distro": "ubuntu:16.04"}, "collection_role":"epel"}
          - {"molecule_image_label": {"distro": "ubuntu:18.04"}, "collection_role":"epel"}
          - {"molecule_image_label": {"distro": "ubuntu:20.04"}, "collection_role":"epel"}
```

Of course, that’s not scalable. So, I gave it a bit of thought. Why don’t we treat each role for what it is? It’s a separate role. Editing Role1 shouldn’t affect Role2 or even need to test Role2 in this situation. So I decided to create multiple workflows. Using GitHub Workflows I created the following structure.

```output
.github
└── workflows
    ├── chrony.yml
    ├── epel.yml
    ├── logrotate.yml
    ├── ntp.yml
    ├── remi_repo.yml
    └── selinux.yml
```

Each workflow is specific to each role, and each one looks similar. This is the template I used.

```yaml
name: "FQCN of the Role"
on: ["push", "pull_request"]
jobs:
  molecule:
    runs-on: ubuntu-18.04
    env:
      PY_COLORS: 1 # allows molecule colors to be passed to GitHub Actions
      ANSIBLE_FORCE_COLOR: 1 # allows ansible colors to be passed to GitHub Actions
    strategy:
      fail-fast: true
      matrix:
        molecule_image_label:
          - distro: centos:7
            command: /usr/sbin/init
          - distro: centos:8
            command: /usr/sbin/init
        collection_role:
          - role_name
    steps:
      - name: Check out code
        uses: actions/checkout@v1
        with:
          path: ansible_collections/dettonville/system
 
      - name: Set up Python 3.8
        uses: actions/setup-python@v1
        with:
          python-version: 3.8
 
      - name: Install dependencies
        run: |
          sudo apt install docker
          python -m pip install --upgrade pip
          pip install molecule yamllint ansible-lint docker
 
      - name: Run role test
        run: >-
          molecule --version &&
          ansible --version &&
          MOLECULE_COMMAND=${{ matrix.molecule_image_label.command }}
          MOLECULE_IMAGE_LABEL=${{ matrix.molecule_image_label.distro }}
          molecule --debug test -s ${{ matrix.collection_role }}

```


You can change the operating systems if you want, this is just one of the examples I had. I solved the issue with the cross-contamination I had earlier, as well as made the tests easier to verify and check, as well as independent test state icons for the README.md. But I still had an issue. If I make a change to Role1, Role2 still builds…not desired and wastes build time against GitHub Actions.

Luckily in GitHub Actions, we can do include, or exclude paths on the trigger. So I replaced this section on: \["push", "pull_request"\] with

```yaml
on:
  push:
    paths:
      - 'roles/role_name/**'
      - 'molecule/role_name/**
      - '.github/workflows/role_name.yml'
  pull_request:
    paths:
      - 'roles/role_name/**'
      - 'molecule/role_name/**
      - '.github/workflows/role_name.yml'
```

So now the role only executes when the items specific to that role are edited. Saving me possibly money, and build time so other jobs in my GitHub can execute.

Now my completed .github/workflow/chrony.yml  looks like this:

```yaml
name: "dettonville.system.chrony"
on:
  push:
    paths:
      - 'roles/chrony/**'
      - '.github/workflows/chrony.yml'
  pull_request:
    paths:
      - 'roles/chrony/**'
      - '.github/workflows/chrony.yml'
jobs:
  molecule:
    runs-on: ubuntu-18.04
    env:
      PY_COLORS: 1 # allows molecule colors to be passed to GitHub Actions
      ANSIBLE_FORCE_COLOR: 1 # allows ansible colors to be passed to GitHub Actions
    strategy:
      fail-fast: true
      matrix:
        molecule_image_label:
          - distro: centos:7
            command: /usr/sbin/init
          - distro: centos:8
            command: /usr/sbin/init
        collection_role:
          - chrony
    steps:
      - name: Check out code
        uses: actions/checkout@v1
        with:
          path: ansible_collections/dettonville/system
 
      - name: Set up Python 3.8
        uses: actions/setup-python@v1
        with:
          python-version: 3.8
 
      - name: Install dependencies
        run: |
          sudo apt install docker
          python -m pip install --upgrade pip
          pip install molecule yamllint ansible-lint docker
 
      - name: Run role test
        run: >-
          molecule --version &&
          ansible --version &&
          MOLECULE_COMMAND=${{ matrix.molecule_image_label.command }}
          MOLECULE_IMAGE_LABEL=${{ matrix.molecule_image_label.distro }}
          molecule --debug test -s ${{ matrix.collection_role }}
```

Since these changes have been made now I am able to ensure that all of my roles are independently tested each time they are edited without treating everything as one giant repo and having tests run for 10+ minutes each as all of my roles execute. Now they are all tested in parallel, and against their own supported operating systems.

To see a copy of the repository used for this you can see [https://github.com/dettonville/ansible-collection-system](https://github.com/dettonville/ansible-collection-system) which you are free to clone, modify, change, use a reference. I did make changes to the Dockerfile because I do not host my own docker images, and don’t plan to. I highly suggested taking a look at my molecule/role_name/Dockerfile.j2  files to get an idea on what I did to get services to work. My changes to Dockerfile.j2 are based on [Multi-distribution Ansible testing with Molecule on Travis-CI](https://dettonville.com/2019/06/23/multi-distribution-ansible-testing-with-molecule-on-travis-ci/), and check out molecule/role_name/molecule.yml  to see how I pass through the parameters.

If you have questions please feel free to comment.

## Reference

* https://dettonville.com/2020/04/30/ansible-collections-role-tests-with-molecule/

