```markdown
# Custom Menus for Self-Hosted netboot.xyz

This directory contains custom iPXE files that are rendered during menu generation and available from the main menu via the custom menu option.

## Configuration

When the following options are set in your configuration:

```yaml
custom_generate_menus: true
custom_templates_dir: "{{ netbootxyz_conf_dir }}/custom"
```

the menu will include an option for custom menus and attempt to load `custom/custom.ipxe`. This allows you to build and maintain custom options separately from the netboot.xyz source tree, enabling independent updates of both menus.

## Sample Menu

A sample menu is provided to demonstrate how to configure and set up a custom menu. You can copy the `custom` directory from the repository:

```bash
cp etc/netbootxyz/custom /etc/netbootxyz/custom
```

### Adding or Improving YAML Frontmatter

Ensure that your custom files include clear YAML frontmatter with fields such as `title`, `original_path`, `category`, and `tags`.

## Backlinks

- [netboot.xyz Documentation](https://github.com/tlindner/netbootxyz)
```

This improved version uses clean, professional Markdown formatting, includes proper headings, and adds a "Backlinks" section for reference.