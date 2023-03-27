# win_authorized_key - Adds or removes an SSH authorized key

## Synopsis

* Ansible module to add or to remove SSH authorized keys for particular user accounts on Windows-based systems.

## Requirements

The below requirements are needed on the host that executes this module.

* Win32 OpenSSH

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
|__user__<br><font color="purple">string</font> / <font color="red">required</font> |  | The username on the remote host whose authorized_keys file will be modified |
|__key__<br><font color="purple">string</font> / <font color="red">required</font> |  | The SSH public key(s), as a string or (since 1.9) url <https://github.com/username.keys> |
|__path__<br><font color="purple">string</font> | __Default:__<br><font color="blue">(homedir)+/.ssh/authorized_keys</font> | Alternate path to the authorized_keys file |
|__manage_dir__<br><font color="purple">boolean</font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | Whether this module should manage the directory of the authorized key file.<br>If set, the module will create the directory, as well as set the owner and permissions of an existing directory.<br>Be sure to set _manage_dir_=`no` if you are using an alternate directory for authorized_keys, as set with `path`, since you could lock yourself out of SSH access. See the example below. |
|__state__<br><font color="purple">string</font> | __Choices__: <ul><li><font color="blue">__present &#x2190;__</font></li><li>absent</li></ul> | Whether the given key (with the given key_options) should or should not be in the file |
|__key_options__<br><font color="purple">string</font> |  | A string of ssh key options to be prepended to the key in the authorized_keys file |
|__exclusive__<br><font color="purple">boolean</font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Whether to remove all other non-specified keys from the authorized_keys file. Multiple keys can be specified in a single _key_ string value by separating them by newlines.<br>This option is not loop aware, so if you use `with_` , it will be exclusive per iteration of the loop, if you want multiple keys in the file you need to pass them all to `key` in a single batch as mentioned above. |
|__validate_certs__<br><font color="purple">boolean</font> | __Choices__: <ul><li>no</li><li><font color="blue">__yes &#x2190;__</font></li></ul> | This only applies if using a https url as the source of the keys.<br>If set to `no`, the SSL certificates will not be validated.<br>This should only set to `no` used on personally controlled sites using self-signed certificates as it avoids verifying the source site. |
|__comment__<br><font color="purple">string</font> |  | Change the comment on the public key. Rewriting the comment is useful in cases such as fetching it from GitHub or GitLab.<br>If no comment is specified, the existing comment will be kept. |
|__follow__<br><font color="purple">boolean</font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Follow path symlink instead of replacing it |

## Examples

```yaml
---
roles:
  - win_authorized_key

tasks:

  - name: Set authorized key taken from file
    win_authorized_key:
      user: charlie
      state: present
      key: "{{ lookup('file', 'c:/users/charlie/.ssh/id_rsa.pub') }}"

  - name: Set authorized keys taken from url
    win_authorized_key:
      user: charlie
      state: present
      key: https://github.com/charlie.keys

  - name: Set authorized key in alternate location
    win_authorized_key:
      user: charlie
      state: present
      key: "{{ lookup('file', 'c:/users/charlie/.ssh/id_rsa.pub') }}"
      path: c:/ProgramData/ssh/administrators_authorized_key
      manage_dir: False

  - name: Set up multiple authorized keys
    win_authorized_key:
      user: deploy
      state: present
      key: '{{ item }}'
    with_file:
      - public_keys/doe-jane
      - public_keys/doe-john

  - name: Set authorized key defining key options
    win_authorized_key:
      user: charlie
      state: present
      key: "{{ lookup('file', 'c:/users/charlie/.ssh/id_rsa.pub') }}"
      key_options: 'no-port-forwarding,from="10.0.1.1"'

  - name: Set authorized key without validating the TLS/SSL certificates
    win_authorized_key:
      user: charlie
      state: present
      key: https://github.com/user.keys
      validate_certs: False

  - name: Set authorized key, removing all the authorized keys already set
    win_authorized_key:
      user: administrator
      key: '{{ item }}'
      state: present
      exclusive: True
    with_file:
      - public_keys/doe-jane

```

## Return Values

Common return values are documented [here](https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html#common-return-values), the following are the fields unique to this module:

| Key    | Returned   | Description |
| ------ |------------| ------------|
|__exclusive__<br><font color="purple">boolean</font> | success | If the key has been forced to be exclusive or not.<br><br>__Sample:__<br><font color=blue>False</font> |
|__key__<br><font color="purple">string</font> | success | The key that the module was running against.<br><br>__Sample:__<br><font color=blue><https://github.com/user.keys></font> |
|__key_option__<br><font color="purple">string</font> | success | Key options related to the key. |
|__keyfile__<br><font color="purple">string</font> | success | Path for authorized key file.<br><br>__Sample:__<br><font color=blue>C:/users/charlie/.ssh/authorized_keys</font> |
|__manage_dir__<br><font color="purple">boolean</font> | success | Whether this module managed the directory of the authorized key file.<br><br>__Sample:__<br><font color=blue>True</font> |
|__path__<br><font color="purple">string</font> | success | Alternate path to the authorized_keys file. |
|__state__<br><font color="purple">string</font> | success | Whether the given key (with the given key_options) should or should not be in the file.<br><br>__Sample:__<br><font color=blue>present</font> |
|__unique__<br><font color="purple">boolean</font> | success | Whether the key is unique.<br><br>__Sample:__<br><font color=blue>False</font> |
|__user__<br><font color="purple">string</font> | success | The username on the remote host whose authorized_keys file will be modified.<br><br>__Sample:__<br><font color=blue>user</font> |
|__validate_certs__<br><font color="purple">boolean</font> | success | This only applies if using a https url as the source of the keys. If set to `no`, the SSL certificates will not be validated.<br><br>__Sample:__<br><font color=blue>True</font> |

