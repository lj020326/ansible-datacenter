
# Notes on how to use yamlfixer

## Install

```shell
pip install yamlfixer-opt-nc
## OR
python3 -m pip install yamlfixer-opt-nc
```

## Show version and command line options/args

```shell
yamlfixer -v
yamlfixer --help
```

## Show the fixer types

```shell
yamlfixer -l
```

## Run fixer on single directory without recursion

```shell
yamlfixer -d --summary inventory/
yamlfixer -d --summary tests/
```

## Run with nochange and summary of fixes

```shell
yamlfixer --nochange --summary .
yamlfixer --nochange --summary --recurse -1 .
yamlfixer --nochange --summary --recurse -1 inventory/
yamlfixer --nochange --summary @save/list-of-yamllint-files.txt
```

## Run without syntax changes

```shell
yamlfixer --nosyntax --help
yamlfixer -N --recurse -1 --summary inventory/
yamlfixer -N --recurse -1 --summary roles/bootstrap-nfs
```

## Run changes on specified path

```shell
yamlfixer --recurse -1 --summary inventory/
yamlfixer --recurse -1 --summary roles/bootstrap-nfs
```

## Run changes with debug to resolve possible parsing issues when fixing

```shell
yamlfixer -d --recurse -1 --summary roles/bootstrap-nfs
yamlfixer -d --recurse -1 --summary roles/bootstrap-postfix
yamlfixer -d --recurse -1 --summary roles/bootstrap-docker
```

## Run using redirection of specified file

```shell
yamllint --list-files . | yamlfixer --nochange --summary -
```

## Run yamllint on results

```shell
yamllint --no-warnings -f parsable . | tee test-results/yamllint-results.txt
```

## Reference

- https://github.com/opt-nc/yamlfixer
