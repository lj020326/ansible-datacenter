
```shell
$ ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(/Users/ljohnson/repos/ansible/ansible-datacenter/ansible.cfg) = ['/Users/foobar/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules', '/Users/foobar/repos/ansible/ansible-datacenter/library']

$ 
```


```shell
$ ansible-doc -t module dettonville.util.git_acp

> dettonville.UTIL.GIT_ACP    (/Users/ljohnson/repos/silex/alsac/dettonville/collections/ansible_collections/dettonville/util/plugins/modules/git_acp.py)

        Manage `git add', `git commit' `git push', `git config' user
        name and email on a local or remote git repository.

OPTIONS (= is mandatory):

- add
        List of files under `path' to be staged. Same as `git add .'.
        File globs not accepted, such as `./*' or `*'.
        [Default: ['.']]
        elements: str
        type: list

- branch
        Git branch where perform git push.
        [Default: main]
        type: str

= comment
        Git commit comment. Same as `git commit -m'.

        type: str

- executable
        Path to git executable to use. If not supplied, the normal
        mechanism for resolving binary paths will be used.
        [Default: (null)]
        added in: version 1.4 of dettonville.util


- mode
        Git operations are performend eithr over ssh, https or local.
        Same as `git@git...' or `https://user:token@git...'.
        (Choices: ssh, https, local)[Default: ssh]
        type: str

= path
        Folder path where `.git/' is located.

        type: path

- push_option
        Git push options. Same as `git --push-option=option'.
        [Default: (null)]
        type: str

- remote
        Local system alias for git remote PUSH and PULL repository
        operations.
        [Default: origin]
        type: str

- ssh_params
        Dictionary containing SSH parameters.
        [Default: None]
        type: dict

        OPTIONS:

        - accept_hostkey
            If `yes', ensure that "-o StrictHostKeyChecking=no" is
            present as an ssh option.
            [Default: no]
            type: bool

        - key_file
            Specify an optional private key file path, on the target
            host, to use for the checkout.
            [Default: (null)]

        - ssh_opts
            Creates a wrapper script and exports the path as GIT_SSH
            which git then automatically uses to override ssh
            arguments. An example value could be "-o
            StrictHostKeyChecking=no" (although this particular option
            is better set via `accept_hostkey').
            [Default: None]
            type: str

- token
        Git API token for https operations.
        [Default: (null)]
        type: str

= url
        Git repo URL.

        type: str

- user
        Git username for https operations.
        [Default: (null)]
        type: str

- user_email
        Explicit git local email address. Nice to have for remote
        operations.
        [Default: (null)]
        type: str

- user_name
        Explicit git local user name. Nice to have for remote
        operations.
        [Default: (null)]
        type: str


REQUIREMENTS:  git>=2.10.0 (the command line tool)

EXAMPLES:

- name: HTTPS | add file1.
  git_acp:
    user: dettonville
    token: mytoken
    path: /Users/git/git_acp
    branch: master
    comment: Add file1.
    remote: origin
    add: [ "." ]
    mode: https
    url: "https://gitlab.com/networkAutomation/git_test_module.git"

- name: SSH | add file1.
  git_acp:
    path: /Users/git/git_acp
    branch: master
    comment: Add file1.
    add: [ file1  ]
    remote: dev_test
    mode: ssh
    url: "git@gitlab.com:networkAutomation/git_test_module.git"
    user_name: dettonville
    user_email: dettonville@gmail.com

- name: LOCAL | push on local repo.
  git_acp:
    path: "~/test_directory/repo"
    branch: master
    comment: Add file1.
    add: [ file1 ]
    mode: local
    url: /Users/federicoolivieri/test_directory/repo.git


RETURN VALUES:
- output
        list of git cli command stdout

        returned: always
        sample: [master 99830f4] Remove [ test.txt, tax.txt ] 4 files changed, 26 insertions(+)...
        type: list
```
