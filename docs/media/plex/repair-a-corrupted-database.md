
# Repair a Corrupted Database

**Note**: This article is for Plex Media Server version 1.23.2 and newer. If using an earlier version, see [our older instructions](https://support.plex.tv/articles/201100678-repair-a-corrupt-database-1-22-0/).

Though rare, it is possible for your main Plex Media Server database to become corrupted. For instance, it might happen if the computer is turned off without first quitting Plex Media Server in certain cases, such as when the database is located on a network share. In such a situation, you can attempt to repair the database.

**Tip!**: It’s always a good idea make a backup copy of the database file before doing any work on it.

In many cases, you may also be able to restore a database copy that was backed up via the Scheduled Tasks feature.

The database file will be located at `/Plug-in Support/Databases/com.plexapp.plugins.library.db` inside the main Plex Media Server data directory. The data directory location can vary by operating system and device; see the article listed below for details. The commands listed below will assume the default server data directory locations.

**Note**: You can also simply delete the `com.plexapp.plugins.library.db` database file while the Plex Media Server is not running. Restarting the server will then restore your server to a nearly-fresh install state. (i.e. You will _lose your existing libraries and need to recreate them_, but you won’t be affecting your content itself.)

**Warning**: With the instructions below, if you run all of the “Check for Corruption” instructions prior to running the “Run a Repair” instructions, you will receive errors related to steps 2 & 3 of the latter. That is expected and the errors won’t affect anything.

**Related Page**: [Where is the Plex Media Server data directory located?](https://support.plex.tv/articles/202915258-where-is-the-plex-media-server-data-directory-located/)  
**Related Page**: [Restore a Database Backed Up via 'Scheduled Tasks'](https://support.plex.tv/articles/202485658-restore-a-database-backed-up-via-scheduled-tasks/)

## Plex SQLite

Plex Media Server includes its own SQLite command line interpreter. Due to customizations included in the Plex database engine, the standard SQLite interpreter is not able to repair the Plex Media Server database. The interpreter can be invoked by running the Plex SQLite executable found in the Plex Media Server installation folder, which will open up a SQLite Shell. You can then run regular SQLite commands in the shell. Plex SQLite can also be used as a command line tool, replacing the standard SQLite3 executable. The examples below are shown using Plex SQLite as a command line to match previous instructions. If you need assistance using the Plex SQLite shell, please post your questions in our support forum.

**Related Page**: [Plex Forums](https://forums.plex.tv/c/plex-media-server/114)

## Locating the Plex SQLite tool

The Plex SQLite tool is located alongside the Plex Media Server executable. You can find it in the following locations, depending on the operating system your server runs on. When the commands below reference `"Plex SQLite"`, fill in the path listed here:

-   **Windows (32-bit)**: `"C:\Program Files (x86)\Plex\Plex Media Server\Plex SQLite.exe"`
-   **macOS**: `"/Applications/Plex Media Server.app/Contents/MacOS/Plex SQLite"`
-   **Linux (desktop)**: `"/usr/lib/plexmediaserver/Plex SQLite"`
-   **QNAP**: `"/share/CACHEDEV1_DATA/.qpkg/PlexMediaServer/Plex SQLite"`
-   **Synology (DSM 6)**: `"/var/packages/Plex Media Server/target/Plex SQLite"`
-   **Synology (DSM 7)**: `"/var/packages/PlexMediaServer/target/Plex SQLite"`

## Opening a database file

Make sure you quit/exit your Plex Media Server so that it is not running. The following commands are run in the **Command Prompt** application. When running the commands, be sure to enclose paths in quotes to handle spaces in paths. First, simply switch over to the directory containing the database:

(**Windows**)

```
cd "%LOCALAPPDATA%\Plex Media Server\Plug-in Support\Databases"
```

(**Other platforms)**

```
cd "[PLEX APPDATA PATH]/Plug-in Support/Databases"
```

Note that you may need to substitute `[PLEX APPDATA PATH]` with the appropriate location for your platform; see [Where is the Plex Media Server data directory located?](https://support.plex.tv/articles/202915258-where-is-the-plex-media-server-data-directory-located/) for more details.

We recommend making a copy of the database before making any changes:

(**Windows**)

```
copy com.plexapp.plugins.library.db com.plexapp.plugins.library.db.original
```

(**Other platforms**)

```
cp com.plexapp.plugins.library.db com.plexapp.plugins.library.db.original
```

Now, you can open the database file using the Plex SQLite tool (make sure to use the path you located previously):

```
"Plex SQLite" com.plexapp.plugins.library.db
```

Within the `sqlite>` shell, you can run the same commands provided by the standard SQLite interpreter. Some useful examples are provided below. To exit the shell safely, type `.quit`.

**Related Page:** [https://sqlite.org/index.html](https://sqlite.org/index.html)

## Useful diagnostic commands

The following commands are meant to be run within the Plex SQLite tool unless otherwise specified. Enter these commands at the `sqlite>` prompt.

### Check for Corruption

You can use this command to check for various types of database corruption:

```
PRAGMA integrity_check;
```

If the result comes back as “ok”, then the database file structure appears to be valid. It’s still possible that there may be other issues that haven’t been detected, such as incorrect formatting in the data itself. If you see an error, you can try to repair it using the commands below. Try running another integrity check after each change to see if it solved your problem.

### Rebuilding the database structure

Some types of issues (including some that aren’t detected by \`integrity\_check\`) can be repaired automatically by rebuilding the database structure using this command:

```
VACUUM;
```

### Rebuilding indexes

Issues relating to database indexes can be resolved by rebuilding them. Index issues often produce `integrity_check` output like this:

```
row 161 missing from index index_metadata_item_settings_on_changed_at
wrong # of entries in index index_metadata_item_settings_on_guid

```

You can rebuild your indexes using this command:

```
REINDEX;
```

### Low-level database recovery

These commands will salvage as much information as possible from a corrupted database, then re-generate the database file from the salvaged data.

First, generate the recovery file (here, we’ll name it `db-recover.sqlite`):

```
.output db-recover.sqlite
.recover

```

Then, exit the SQLite shell (using the `.quit` command) and move the .db file aside (you can either place it in a different folder, or rename it). Make sure to keep it as a backup for now! Once the original corrupted database has been moved, start the SQLite shell back up using the same command as before, then run the following command:

```
.read db-recover.sqlite

```

This will reassemble your database with all the valid data that was previously found.

On Linux, after re-generating the database, make sure to check that the correct user owns the new file.  It should match the existing files in the directory, usually similar to the following:

-   **Desktop Linux**: `plex:plex`
-   **QNAP**: `admin:administrators`
-   **Synology (DSM 6)**: `plex:users`
-   **Synology (DSM 7)**: `PlexMediaServer:PlexMediaServer`

**Note**: Even if your integrity check passes without errors, attempting a database repair can still sometimes help.

Last modified on: June 19, 2022

## Reference

* https://support.plex.tv/articles/repair-a-corrupted-database/
* https://forums.plex.tv/t/plex-media-server-database-disk-image-is-malformed/401998
* https://support.plex.tv/articles/202485658-restore-a-database-backed-up-via-scheduled-tasks/
