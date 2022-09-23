
# Find Usage

## Sorting find results

To find files in date sorted order. Here, ‘-nk1‘ means first field and ‘n’ ahead of it means numerical sort.

```shell
find . -name "*.py" -type f -printf "\n%AD %AT %p" |sort -nk1
```

To find files in time sorted order. Here, we added ‘-nk2‘ which means to sort by the second field (time output column) and ‘n’ ahead of it means numerical sort.

```shell
find . -name "*.py" -type f -printf "\n%AD %AT %p" |sort -nk1 -nk2
```

## Use find to delete directories older than specified time

### older than X days

To remove directories older than 14 days

```shell
find /path/ -name "FOLDER_*-*-*_*" -mtime +14 -type d | xargs rm -f -r;
```


### older than X hours

To remove directories older than 360 minutes

```shell
find /path/ -name "FOLDER_*-*-*_*" -mmin +360 -type d | xargs rm -f -r;
```

### Delete files older than..

Older than 360 minutes
```shell
find $LOCATION -name $REQUIRED_FILES -type f -mmin +360 -delete
```

## References

* https://www.tecmint.com/find-and-sort-files-modification-date-and-time-in-linux/
* https://unix.stackexchange.com/questions/367992/find-files-in-the-order-of-timestamp
* https://stackoverflow.com/questions/39216204/linux-delete-directories-which-are-older-than-x-days
* https://stackoverflow.com/questions/249578/how-to-delete-files-older-than-x-hours
* 