
# rsync notes

## How to setup rsyncd on mac os x

### Reference
* https://www.jafdip.com/how-to-setup-rsyncd-on-mac-os-x/
* http://www.fredshack.com/docs/rsync.html
* https://linuxconfig.org/how-to-setup-the-rsync-daemon-on-linux
* https://man7.org/linux/man-pages/man5/rsyncd.conf.5.html

## How to include ssh options in rsync

### Reference
* https://unix.stackexchange.com/questions/111526/how-can-i-rsync-without-prompt-for-password-without-using-public-key-authentica

To specify custom privatekey explicitly:

```shell
rsync -e"ssh -i /path/to/privateKey" -avR $sourcedir ${ruser}@${rhost}:~/${rdir}/
```

## How to rsync with elevated used on remote server

### Reference
* https://unix.stackexchange.com/questions/240814/rsync-with-different-user
* https://github.com/ansible/ansible/issues/4676

use "--rsync-path" arg:

```shell
rsync --rsync-path 'sudo -u jenkins rsync' -avP --delete /var/lib/jenkins destuser@destmachine:/tmp

rsync --delay-updates --compress --archive --rsh 'ssh  -o StrictHostKeyChecking=no'  ~/foo root@el5.lab.net:~jill/bar --rsync-path='sudo -u jill rsync'

rsync -arP -e'ssh -o StrictHostKeyChecking=no' --rsync-path 'sudo -u root rsync' ansible@control.johnson.int:/usr/share/ca-certs /usr/share/

rsync -arP -e'ssh -o StrictHostKeyChecking=no' --rsync-path 'sudo -u root rsync' ansible@control.johnson.int:/usr/local/share/ca-certificates/* /usr/local/share/ca-certificates/

```


## How to mirror drives

### Reference
* https://francium.cc/blog/using-rsync-to-efficiently-backup-mirror-hard-drives/
* https://lifehacker.com/geek-to-live-mirror-files-across-systems-with-rsync-196122
* https://serverfault.com/questions/25329/using-rsync-to-backup-to-an-external-drive/25398

## How to use rsync for backups

### Reference
* https://github.com/lj020326/rsync-incremental-backup
* https://github.com/pedroetb/rsync-incremental-backup
* http://www.admin-magazine.com/Articles/Using-rsync-for-Backups
* http://www.admin-magazine.com/Articles/Using-rsync-for-Backups/(offset)/2
* http://www.mikerubel.org/computers/rsync_snapshots/
* http://stackoverflow.com/questions/4585929/how-to-use-cp-command-to-exclude-a-specific-directory

```shell
#!/usr/bin/env bash

FROM=~/repos/python/superset-dev/
TO=~/repos/python/mwviz/

echo "**********************************"
echo "*** Syncing from $FROM to $TO"
echo "**********************************"

##rsync -arv --update --exclude=.idea --exclude=node_modules --exclude=venv superset-dev/ mwviz/
#rsync -arv --update --progress --exclude=.idea --exclude=node_modules --exclude=venv $FROM $TO
rsync -arv --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv $FROM $TO

## sync from completed to books
rsync -arv --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv Intro* /data/media/books/Infrastructure/Docker

```

## How to use rsync to sync local and remote directories on a vps

### Reference
* https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

```shell
rsync -a ~/dir1 username@remote_host:destination_directory

rsync -a username@remote_host:/home/username/dir1 place_to_sync_on_local_machine

rsync -arv administrator@admin2.johnson.local:/etc/nginx/ssl nginx/

rsync -arv administrator@admin01.dettonville.int:/usr/share/ca-cert /usr/share/

rsync -arv --update --progress somedir /data/media/tutorials/Certifications/Oracle/

rsync -arv --update --progress --exclude=.* /data/media/torrents/completed/ .

```

Example with ssh
```shell
rsync -arP -e'ssh -o StrictHostKeyChecking=no' \
    file.txt \
    ansible@host01.example.int:/opt/data/

```

Example with ssh and sudo
```shell
rsync -arP -e'ssh -i ~/.ssh/cert.id_rsa -o StrictHostKeyChecking=no' \
    --rsync-path 'sudo -u root rsync' \
    file.txt \
    ansible@host01.example.int:/opt/data/

```

```shell
sshpass -p password \
    rsync -arP -e'ssh -o StrictHostKeyChecking=no' \
    --rsync-path 'sudo -u root rsync' \
    file.txt \
    ansible@host01.example.int:/opt/data/

```

Alternative using scp
```shell
scp -i ~/.ssh/cert.id_rsa rhel-8.8-x86_64-dvd.iso username@host01.example.int:/var/tmp/
```
