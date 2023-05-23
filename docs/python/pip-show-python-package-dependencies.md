
# Pip: Show Python Package Dependencies

The dependencies of the installed Python packages can be listed using the built-in `pip show` command.

Alternatively the dependencies can be shown as a tree structure using the `pipdeptree` command.

In this note i will show several examples of how to list dependencies of the installed Python packages.

**Cool Tip:** How to install specific version of a package using `pip`! [Read More →](https://www.shellhacks.com/pip-install-specific-version-of-package/)

Use the built-in `pip show` command to list dependencies of the Python packages that has already been installed, e.g.:

```shell
$ pip show Flask
Name: Flask
Version: 1.1.2
...
Requires: click, Werkzeug, itsdangerous, Jinja2

```

Show requirements of the all installed Python packages:

```shell
$ pip freeze | cut -d "=" -f1 |\
                    xargs pip show |\
                    grep -i "^name\|^version\|^requires"
```

**Cool Tip:** How to list all the locally installed Python modules and find the paths to their source files! [Read More →](https://www.shellhacks.com/python-module-path-list-modules-get-locations/)

If you don’t mind installing new packages, you can install the `pipdeptree` that displays information about the dependencies as a tree structure:

```shell
$ pip install pipdeptree
$ pipdeptree
skywriter==0.0.7
  - RPi.GPIO [required: Any, installed: 0.7.0]
touchphat==0.0.1
  - cap1xxx [required: Any, installed: 0.1.3]
    - RPi.GPIO [required: Any, installed: 0.7.0]
...

```

It also can show the dependency tree in the reverse fashion, i.e. list the sub-dependencies with the list of Python packages that require them:

```shell
$ pipdeptree -r -p RPi.GPIO
RPi.GPIO==0.7.0
  - automationhat==0.2.0 [requires: RPi.GPIO]
  - blinkt==0.1.2 [requires: RPi.GPIO]
  - Cap1xxx==0.1.3 [requires: RPi.GPIO]
    - drumhat==0.1.0 [requires: cap1xxx]
...
```

## Reference

- https://www.shellhacks.com/pip-show-python-package-dependencies/
- https://stackoverflow.com/questions/9232568/identifying-the-dependency-relationship-for-python-packages-installed-with-pip
- 