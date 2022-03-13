# Ansible role `cobbler`

An Ansible role for PURPOSE. Specifically, the responsibilities of this role are to:

-

## Requirements

No specific requirements

## Role Variables


| Variable                           | Required | Default   | Comments (type)                                                                |
| :---                               | :---     | :---      | :---                                                                           |
| `cobbler_default_password_crypted` | no       | (cobbler) | MD-5 crypted hash containing the root password for systems set up with Cobbler |
|                                    |          |           |                                                                                |

## Dependencies

No dependencies.

## Example Playbook

See the [test playbook](tests/test.yml)

## Testing

The `tests` directory contains tests for this role in the form of a Vagrant environment. The directory `tests/roles/cobbler` is a symbolic link that should point to the root of this project in order to work. To create it, do

```ShellSession
$ cd tests/
$ mkdir roles
$ ln -frs ../../PROJECT_DIR roles/cobbler
```

You may want to change the base box into one that you like. The current one is based on Box-Cutter's [CentOS Packer template](https://github.com/boxcutter/centos).

The playbook [`test.yml`](tests/test.yml) applies the role to a VM, setting role variables.

## Contributing

Issues, feature requests, ideas are appreciated and can be posted in the Issues section. Pull requests are also very welcome. Preferably, create a topic branch and when submitting, squash your commits into one (with a descriptive message).

## License

BSD

## Author Information

Bert Van Vreckem (bert.vanvreckem@gmail.com)
