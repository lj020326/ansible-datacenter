---
title: Custom Menus for Self-Hosted netboot.xyz
category: netboot.xyz
tags: [netboot, iPXE, custom menus, self-hosted]
---

# Custom Menus for Self-Hosted netboot.xyz

This directory contains custom iPXE files that are rendered during menu generation and are available from the main menu via the custom menu option.

## Configuration

When the following options are set in your configuration:

```yaml
custom_generate_menus: true
custom_templates_dir: "{{ netbootxyz_conf_dir }}/custom"
```

the menu will add an option for custom menus and attempt to load `custom/custom.ipxe`. From there, custom options can be built and maintained separately from the netboot.xyz source tree, allowing both menus to be updated independently.

## Setup

A sample menu is provided to demonstrate how to configure and set up a menu. You can copy the custom directory from the repository:

```bash
cp etc/netbootxyz/custom /etc/netbootxyz/custom
```

## What is iPXE?

iPXE is an open-source network boot firmware. It provides a flexible network booting environment, and can be integrated with netboot.xyz to create custom boot menus.

Learn more about iPXE at [ipxe.org](https://ipxe.org).

## Creating Custom Menus

The `custom.ipxe` file should contain iPXE script commands that define your custom menu options. Here is an example of a simple custom menu:

```ipxe
:start
menu Custom netboot.xyz Menu
item shell Shell
item reboot Reboot
item exit Exit
choose option && goto ${option}
```

## Updating Custom Menus

After making changes to your custom menu files, you will need to regenerate the menus. This can be done by running the following command:

```bash
netbootxyz-generate-menus
```

## Troubleshooting

If the custom menu does not appear or behaves unexpectedly:
- Ensure that the `custom.ipxe` file exists and is readable.
- Check the netboot.xyz logs for any error messages related to menu generation.
- Verify that the `custom_templates_dir` path is correctly set in your configuration.

## Backlinks

[Back to netboot.xyz Documentation](https://netboot.xyz/docs)