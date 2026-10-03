# bootstrap_hddtemp

This Ansible role installs and configures `hddtemp` on Debian-based systems.

## Description

The `bootstrap_hddtemp` role is designed to set up `hddtemp`, a utility for monitoring hard disk temperatures, on Debian-based systems. It ensures that `hddtemp` is installed and properly configured to provide temperature readings for hard drives.

## Features

- Installs `hddtemp` package
- Configures `hddtemp` service
- Ensures `hddtemp` is enabled and running

## Requirements

- Ansible 2.9 or later
- Debian-based operating system

## Role Variables

The following variables can be set to customize the behavior of this role:

- `hddtemp_version`: Specify the version of `hddtemp` to install (default: latest)
- `hddtemp_service_enabled`: Boolean to enable or disable the `hddtemp` service (default: true)

## Dependencies

None.

## Example Playbook

Here is an example of how to use this role in a playbook:

```yaml
- hosts: debian_servers
  roles:
    - role: bootstrap_hddtemp
      hddtemp_version: "0.3-beta15"
      hddtemp_service_enabled: true
```

## License

This project is licensed under the MIT License. See the [LICENSE](https://opensource.org/licenses/MIT) file for details.

## Author Information

This role was created by [Your Name]. For questions or feedback, please contact [your.email@example.com](mailto:your.email@example.com) or open an issue on GitHub.

## Usage

To use this role, include it in your playbook and set the desired variables. The role will install and configure `hddtemp` on the target hosts.

## Troubleshooting

If you encounter issues with this role, please check the following:

- Ensure that the target hosts are running a Debian-based operating system.
- Ensure that Ansible is installed and configured correctly on the control machine.
- Check the logs for any error messages or warnings.

## Testing

To test this role, run the playbook on a Debian-based system and verify that `hddtemp` is installed and running correctly. You can use the following command to check the status of the `hddtemp` service:

```bash
sudo systemctl status hddtemp
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue on GitHub.

## Changelog

- 2026-08-07: Initial release

## FAQ

### How do I check the temperature of my hard drives?

You can use the `hddtemp` command to check the temperature of your hard drives. For example:

```bash
sudo hddtemp /dev/sda
```

### How do I enable the `hddtemp` service?

The `hddtemp` service is enabled by default. You can enable it manually using the following command:

```bash
sudo systemctl enable hddtemp
```

### How do I disable the `hddtemp` service?

You can disable the `hddtemp` service using the following command:

```bash
sudo systemctl disable hddtemp
```

## Screenshots

![hddtemp service running](https://example.com/hddtemp-service-running.png)

## Demo

[Watch a demo of the `bootstrap_hddtemp` role in action](https://example.com/bootstrap_hddtemp-demo.mp4)