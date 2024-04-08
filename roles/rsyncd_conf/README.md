Configure rsyncd
-------------

This role is used to synchronize filesystem between hosts using the rsync deamon.It removes the rsync configuration after executing the rsync command


Role Variables
--------------
local_filesystem_path: This si the filsystem in the source which needs to be transfered
remote_filesystem_path: This si the file system on the remote host
remote_host: This is the remote host
source_host: This is the source host

Dependencies
------------
Need root privileges

Example Playbook
----------------

```yml
    ---
    - name: synchronise file systems
      hosts: localhost
      gather_facts: no
      become: true
      roles:
        - rsyncd_conf
```
