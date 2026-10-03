harvested_date: '2023-10-05T18:07:09.284014+00:00'
original_path: roles/bootstrap_linux_core/files/scripts/backups/README.md
source_type: legacy_markdown
title: rsync-incremental-backup
category: Backup Solutions
tags:
  - rsync
  - backup
  - incremental backup
  - bash script
  - Linux
---

# rsync-incremental-backup

Configurable bash scripts to send incremental backups of your data to a local or remote target, using [rsync](https://download.samba.org/pub/rsync/rsync.html).

## References

- [rsync-incremental-backup GitHub Repository](https://github.com/pedroetb/rsync-incremental-backup)
- [Mike Rubel's Rsync Snapshots](http://www.mikerubel.org/computers/rsync_snapshots/)
- [Admin Magazine: Using rsync for Backups](http://www.admin-magazine.com/Articles/Using-rsync-for-Backups)
- [How-To Geek: How to Use rsync to Backup Your Data on Linux](https://www.howtogeek.com/135533/how-to-use-rsync-to-backup-your-data-on-linux/)

## Description

These scripts perform (as many as you want) incremental backups of a desired directory to another local or remote directory. The source directory acts as the master (doesn't get modified), making copies of itself in the target directory (slave). You can then browse the slave directory to retrieve any file included in any previous backup.

Only new or modified data is stored (because it's incremental), so the size of backups doesn't grow excessively.

If a backup process gets interrupted, don't worry. You can continue it in the next run of the script without data loss and without resending previously transferred data.

Additionally, there is a local backup script with special configuration, oriented to perform backups for a GNU/Linux filesystem. For example, it already omits temporary, removable, and other problematic paths, and is meant to backup to an external mount point (at `/mnt`).

## Configuration

You can set some configuration variables to customize the script:

- `freq`: Frequency label for the backups. Overwritable by parameters.
- `src`: Path to source directory. Backups will include its content. May be a relative or absolute path. Overwritable by parameters.
- `dst`: Path to target directory. Backups will be placed here. **Must** be an absolute path. Overwritable by parameters.
- `remote`: *ssh_config* host name to connect to remote host (only for remote version). Overwritable by parameters.
- `backupDepth`: Number of backups to keep. When the limit is reached, the oldest get deleted.
- `timeout`: Timeout to cancel the backup process if it's not responding.
- `pathBak0`: Directory inside `dst` where the most recent backup is stored.
- `partialFolderName`: Directory inside `dst` where partial files are stored.
- `rotationLockFileName`: Name given to the rotation lock file, used for detecting previous backup failures.
- `pathBakN`: Directory inside `dst` where the rest of the backups are stored.
- `nameBakN`: Name of incremental backup directories. An index will be added at the end to show how old they are.
- `logName`: Name given to the log file generated at backup.
- `exclusionFileName`: Name given to the text file that contains exclusion patterns. You must create it inside the directory defined by `ownFolderName`.
- `ownFolderName`: Name given to the folder inside the user's home to hold configuration files and logs while the backup is in progress.
- `logFolderName`: Directory inside `dst` where the log files are stored.
- `dateCmd`: Command to run for GNU `date`
- `interactiveMode`: Flag to allow password login, when set to `yes` (only for remote version).

All files and folders in the backup (local and remote only) get read permissions for all users, since a non-readable backup is useless. If you are worried about permissions, you can add a security layer on backup access level (FTP accounts protected with passwords, for example). You can also preserve original files and folders permissions by removing the `--chmod=+r` flag from the script. In system backup, the original permissions are preserved by default.

## Usage

### Setting up *ssh_config* (for remote version)

This script is meant to run without user intervention, so you need to authorize your source machine to access the remote machine. To accomplish this, you should use *ssh keys* to identify you and set a *ssh host* to use them properly.

There are lots of tutorials dedicated to these topics, you can follow one of them. I won't go into more detailed explanation on this, but here are some good references:

- [How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
- [OpenSSH Config File Examples](https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/)

After that, you should use the `Host` value from your *ssh config file* as the `remote` value in the script.

If you really need to use this script without SSH keys authentication, don't worry. You can set the `interactiveMode` configuration variable to `yes`, and you will be prompted for a password (only once) if needed. This is useful for manual backup when the remote server requires authentication via passphrase.

### Customizing configuration values

You have to set, at least, `src` and `dst` (and `remote` in the remote version) values, directly in the scripts or by positional parameters when running them:

- `./rsync-incremental-backup-local /new/path/to/source /new/path/to/target` (`src` and `dst`).
- `./rsync-incremental-backup-remote /new/path/to/source /new/path/to/target new_ssh_remote` (`src`, `dst`, and `remote`).
- `./rsync-incremental-backup-system /mnt/new/path/to/target` (only `dst`, `src` is always *root* in this case).

If you want to exclude some files or directories from the backup, add their paths (relative to backup root) to the text file referenced by `exclusionFileName`.

Once configured with your own variable values, you can simply run the script to begin the backup process.

In addition, all configuration variables, except those that are overwritable by parameters (`src`, `dst`, and `remote`), can be changed from outside by setting the variable before script execution (or exporting it as an environment variable). For example, changing `ownFolderName` variable without editing the script:

```
ownFolderName=".backup" rsync-incremental-backup-remote /path/to/src /path/to/dst user@remote

# Or using an environment variable (maybe set at user session startup)
export ownFolderName=".backup"
rsync-incremental-backup-remote /path/to/src /path/to/dst user@remote
```

### Automating backups

Personally, I schedule it to run every week with [anacron](https://en.wikipedia.org/wiki/Anacron) in user mode. This way, I don't need to remember running it.

To use anacron in user mode, you have to follow these steps:

1. Create an `.anacron` folder in your home directory with subfolders `etc` and `spool`.

    ```bash
    mkdir -p ~/.anacron/etc ~/.anacron/spool
    ```

2. Create an `anacrontab` file at `~/.anacron/etc` with this content (or equivalent, be sure to specify the right path to the script):

    ```bash
    # /etc/anacrontab: configuration file for anacron

    # See anacron(8) and anacrontab(5) for details.

    SHELL=/bin/bash
    PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    START_HOURS_RANGE=8-22

    # period delay job-identifier command
    7 5 weekly_backup ~/bin/rsync-incremental-backup-remote
    ```

3. Make your anacron start at login. Add this content at the end of your `~/.profile` file:

    ```bash
    # User anacron
    /usr/sbin/anacron -s -t ${HOME}/.anacron/etc/anacrontab -S ${HOME}/.anacron/spool
    ```

### Checking backup content

If you are using the default folder names, the newest data backup will be inside `<dst>/data`. The second newest backup will be inside `<dst>/backup/backup.1`, the next will be inside `<dst>/backup/backup.2`, and so on. Log files per backup operation will be stored at `<dst>/log`.

## Used *rsync* Flags Explanation

- `-a`: archive mode; equals `-rlptgoD` (no `-H,-A,-X`). Mandatory for backup usage.
- `-c`: skip based on checksum, not mod-time & size. More trustworthy, but slower. Omit this flag if you want faster backups, but files without changes in modified time or size won't be detected for inclusion in the backup.
- `-h`: output numbers in a human-readable format.
- `-v`: increase verbosity for logging.
- `-z`: compress file data during the transfer. Less data transmitted, but slower. Omit this flag when the backup target is a local device or a machine in the local network (or when you have a high bandwidth to a remote machine).
- `--progress`: show progress per file during transfer. Only for interactive usage.
- `--timeout`: set I/O timeout in seconds. If no data is transferred for the specified time, the backup will be aborted.
- `--delete`: delete extraneous files from dest dirs. Mandatory for master-slave backup usage.
- `--link-dest`: hardlink to files in the specified directory when unchanged, to reduce storage usage by duplicated files between backups.
- `--log-file`: log what we're doing to the specified file.
- `--chmod`: affect file and/or directory permissions.
- `--exclude`: exclude files matching pattern.
- `--exclude-from`: same as `--exclude`, but getting patterns from the specified file.

Used only for remote backup:
- `--no-W`: ensures that rsync's delta-transfer algorithm is used, so it never transfers whole files if they are present at the target. Omit only when you have a high bandwidth to the target, backup may be faster.
- `--partial-dir`: put a partially transferred file into the specified directory, instead of using a hidden file in the original path of the transferred file. Mandatory for allowing partial transfers and avoiding misleads with incomplete/corrupt files.

Used only for local backups:
- `-W`: ignores rsync's delta-transfer algorithm, so it always transfers whole files. When you have a high bandwidth to the target (local filesystem or LAN), the backup may be faster.

Used only for system backup:
- `-A`: preserve ACLs (implies `-p`).

Used only for log sending:
- `-r`: recurse into directories.
- `--remove-source-files`: sender removes synchronized files (non-dir).

## References

This was inspired by:

- [Incremental Backups on Linux](http://www.admin-magazine.com/Articles/Using-rsync-for-Backups).
- [Rsync full system backup](https://wiki.archlinux.org/index.php/Rsync#Full_system_backup).

## Backlinks

<!-- Add backlinks here if applicable -->