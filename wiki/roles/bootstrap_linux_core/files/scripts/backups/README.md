```markdown
---
title: rsync-incremental-backup Documentation
original_path: roles/bootstrap_linux_core/files/scripts/backups/README.md
category: Backup Scripts
tags: [rsync, backup, incremental, linux]
---

# rsync-incremental-Backup

Configurable bash scripts to send incremental backups of your data to a local or remote target using [rsync](https://download.samba.org/pub/rsync/rsync.html).

## References

- [GitHub Repository](https://github.com/pedroetb/rsync-incremental-backup)
- [Using rsync Snapshots](http://www.mikerubel.org/computers/rsync_snapshots/)
- [Admin Magazine: Using rsync for Backups](http://www.admin-magazine.com/Articles/Using-rsync-for-Backups)
- [How To Use Rsync to Backup Your Data on Linux](https://www.howtogeek.com/135533/how-to-use-rsync-to-backup-your-data-on-linux/)

## Description

These scripts perform incremental backups of a specified directory to another local or remote directory. The source directory acts as the master (unchanged), while the target directory stores copies of the source.

Key features:
- Incremental backups store only new or modified data, keeping backup sizes manageable.
- Interrupted backups can be resumed without data loss.
- A specialized local backup script is included for GNU/Linux filesystems, excluding temporary and removable paths by default.

## Configuration

You can customize the scripts using configuration variables:

- `freq`: Frequency label for backups (overwritable by parameters).
- `src`: Source directory path (relative or absolute; overwritable by parameters).
- `dst`: Target directory path (absolute; overwritable by parameters).
- `remote`: SSH config host name for remote connections (only for remote version; overwritable by parameters).
- `backupDepth`: Number of backups to retain. Oldest backups are deleted when the limit is reached.
- `timeout`: Timeout duration to cancel unresponsive backup processes.
- `pathBak0`: Directory in `dst` for the most recent backup.
- `partialFolderName`: Directory in `dst` for partial files.
- `rotationLockFileName`: Name of the rotation lock file used to detect previous backup failures.
- `pathBakN`: Directory in `dst` for older backups.
- `nameBakN`: Naming convention for incremental backup directories, with an index indicating age.
- `logName`: Name of the log file generated during backups.
- `exclusionFileName`: Name of the text file containing exclusion patterns (must be created inside `ownFolderName`).
- `ownFolderName`: Name of the folder in the user's home directory for configuration files and logs during backup.
- `logFolderName`: Directory in `dst` for storing log files.
- `dateCmd`: Command to run GNU `date`.
- `interactiveMode`: Flag to allow password login (only for remote version).

All files and directories in backups receive read permissions for all users. To preserve original permissions, remove the `--chmod=+r` flag from the script.

## Usage

### Setting up SSH Config (for Remote Version)

To run the script without user intervention, configure SSH keys and set an SSH host:

1. **Generate SSH Keys**: Follow tutorials like [How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).
2. **Configure SSH Host**: Refer to [OpenSSH Config File Examples](https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/).

Use the `Host` value from your SSH config file as the `remote` value in the script.

For manual backups requiring authentication, set `interactiveMode` to `yes`.

### Customizing Configuration Values

Set at least `src`, `dst`, and `remote` (for remote version) values directly in the scripts or via positional parameters:

- **Local Backup**: `$ ./rsync-incremental-backup-local /new/path/to/source /new/path/to/target`
- **Remote Backup**: `$ ./rsync-incremental-backup-remote /new/path/to/source /new/path/to/target new_ssh_remote`
- **System Backup**: `$ ./rsync-incremental-backup-system /mnt/new/path/to/target` (source is always `/`)

Exclude files or directories by adding their paths to the file referenced by `exclusionFileName`.

Override configuration variables without editing the script:

```bash
$ ownFolderName=".backup" rsync-incremental-backup-remote /path/to/src /path/to/dst user@remote

# Or using an environment variable
$ export ownFolderName=".backup"
$ rsync-incremental-backup-remote /path/to/src /path/to/dst user@remote
```

### Automating Backups

Schedule backups using [anacron](https://en.wikipedia.org/wiki/Anacron) in user mode:

1. **Create Anacron Directories**:
   ```bash
   $ mkdir -p ~/.anacron/etc ~/.anacron/spool
   ```

2. **Configure Anacrontab** (`~/.anacron/etc/anacrontab`):
   ```
   SHELL=/bin/bash
   PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
   START_HOURS_RANGE=8-22

   # period delay job-identifier command
   7 5 weekly_backup ~/bin/rsync-incremental-backup-remote
   ```

3. **Start Anacron at Login** (`~/.profile`):
   ```
   # User anacron
   /usr/sbin/anacron -s -t ${HOME}/.anacron/etc/anacrontab -S ${HOME}/.anacron/spool
   ```

### Checking Backup Content

Default folder names store:
- Newest data in `<dst>/data`.
- Older backups in `<dst>/backup/backup.1`, `<dst>/backup/backup.2`, etc.
- Log files at `<dst>/log`.

## Used `rsync` Flags Explanation

- `-a`: Archive mode; equals `-rlptgoD` (no `-H,-A,-X`). Mandatory for backups.
- `-c`: Skip based on checksum, not mod-time & size. More trustworthy but slower.
- `-h`: Output numbers in a human-readable format.
- `-v`: Increase verbosity for logging.
- `-z`: Compress file data during transfer. Less data transmitted but slower.
- `--progress`: Show progress per file (interactive usage).
- `--timeout`: Set I/O timeout in seconds; aborts backup if no data is transferred.
- `--delete`: Delete extraneous files from destination directories.
- `--link-dest`: Hardlink to unchanged files in specified directory, reducing storage usage.
- `--log-file`: Log actions to the specified file.
- `--chmod`: Affect file and/or directory permissions.
- `--exclude`: Exclude files matching pattern.
- `--exclude-from`: Same as `--exclude`, patterns from specified file.

**Remote Backup Flags:**
- `--no-W`: Use rsync's delta-transfer algorithm; omit for high bandwidth.
- `--partial-dir`: Store partially transferred files in specified directory.

**Local Backup Flags:**
- `-W`: Ignore rsync's delta-transfer algorithm; always transfer whole files.

**System Backup Flags:**
- `-A`: Preserve ACLs (implies `-p`).

**Log Sending Flags:**
- `-r`: Recurse into directories.
- `--remove-source-files`: Sender removes synchronized files (non-dir).

## Backlinks

- [GitHub Repository](https://github.com/pedroetb/rsync-incremental-backup)
```

This improved Markdown document maintains the original content and meaning while adhering to clean, professional formatting standards suitable for GitHub rendering.