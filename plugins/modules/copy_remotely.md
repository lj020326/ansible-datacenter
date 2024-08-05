
```shell
$ ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(/Users/ljohnson/repos/ansible/ansible-datacenter/ansible.cfg) = ['/Users/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules', '/Users/ljohnson/repos/ansible/ansible-datacenter/library']

$ 
```


```shell
$ ansible-doc -t module copy_remotely

> COPY_REMOTELY    (/Users/ljohnson/repos/ansible/ansible-datacenter/library/copy_remotely.py)

        Copies a file but, unlike the [file] module, the copy is
        performed on the remote server. The copy is only performed if
        the source and destination files are different (different MD5
        sums) or if the destination file does not exist. The
        destination directory is created if missing.

ADDED IN: version 

OPTIONS (= is mandatory):

= dest
        Path to the destination file.
        [Default: None]

= src
        Path to the file to copy.
        [Default: None]


REF: https://fossies.org/linux/ansible/lib/ansible/modules/files/copy.
        py

SOURCE: https://gist.github.com/aseigneurin/4902819f17218340d11f

EXAMPLES:

- copy_remotely: src=/tmp/foo.conf dest=/etc/foo.conf

```
