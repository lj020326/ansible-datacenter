```markdown
---
title: Dependency Management for AWX Docker Bootstrap
original_path: roles/bootstrap_awx_docker/files/requirements/README.md
category: Development
tags: [dependency-management, awx, docker, requirements]
---

# Dependency Management

The `requirements.txt` and `requirements_ansible.txt` files are generated from `requirements.in` and `requirements_ansible.in`, respectively, using `pip-tools` (`pip-compile`).

## How To Use

Run the following commands from inside the `./requirements` directory of the AWX repository.

Ensure you have the following tools installed: `patch`, `awk`, `python3`, `python2`, `python3-venv`, `python2-virtualenv`, `pip2`, and `pip3`. The development container image should include all these dependencies.

### Upgrading or Adding Select Libraries

To add or upgrade a specific library, modify the `requirements.in` file, then run:

```bash
./updater.sh
```

#### Upgrading Unpinned Dependencies

If you need to update a dependency that does not have a pinned version, specify a minimum version in `requirements.in` and run `./updater.sh`. For example, change `asgi-amqp` to `asgi-amqp>=1.1.4`, and consider adding a comment.

The next time general upgrades are performed, the minimum version specifiers can be removed as the `*.txt` files will be updated to the latest versions.

### Upgrading Dependencies

To upgrade all dependencies, run:

```bash
./updater.sh upgrade
```

## What The Script Does

This script performs the following actions:

- Updates `requirements.txt` based on `requirements.in`.
- Updates/generates `requirements_ansible.txt` based on `requirements_ansible.in`, including an automated patch to add `python_version < "3"` for Python 2 backward compatibility.

## Licenses and Source Files

If a library's license changes with an upgrade, update the corresponding license file in `docs/licenses`.

For libraries that require source distributions (e.g., LGPL), keep a tarball of the library along with its license. To download the PyPI tarball, use:

```bash
pip download <pypi-library-name> -d docs/licenses/ --no-binary :all: --no-deps
```

Ensure you delete the old tarball if it is an upgrade.

## UPGRADE BLOCKERS

Anything pinned in `*.in` files requires additional manual work to upgrade. Here are some specific considerations:

### django

For any Django upgrade, ensure FIPS support is not regressed before merging. Refer to the internal integration test knowledge base article `how_to_test_FIPS` for instructions.

In a FIPS environment, `hashlib.md5()` raises a `ValueError`, but supports the `usedforsecurity` keyword on RHEL and CentOS systems. Monitor [Django ticket 28401](https://code.djangoproject.com/ticket/28401) for updates.

The override of `names_digest` could be broken in future versions. Verify that the import remains consistent in the desired version, as seen in [this commit](https://github.com/django/django/blob/af5ec222ccd24e81f9fec6c34836a4e503e7ccf7/django/db/backends/base/schema.py#L7).

### social-auth-app-django

`django-social` gathers backends in memory based on `settings.AUTHENTICATION_BACKENDS` at import time. Since our settings can change dynamically, overwrite this value at the start of every request to ensure it is up-to-date.

See [this issue](https://github.com/ansible/tower/issues/1979) for more details.

### django-oauth-toolkit

Version 1.2.0 has a bug when revoking tokens, fixed in the master branch but not yet released. When upgrading past 1.2.0, edit the `0025` migration to remove the `validate_uris` validator method, as done in [this commit](https://github.com/jazzband/django-oauth-toolkit/commit/96538876d0d7ea0319ba5286f9bde842a906e1c5).

### azure-keyvault

Upgrading to 4.0.0 causes import errors due to changed imports:

```python
from azure.keyvault import KeyVaultClient, KeyVaultAuthentication
ImportError: cannot import name 'KeyVaultClient'
```

### slackclient

Imports in `awx/main/notifications/slack_backend.py` changed in version 2.0. Update and re-test the plugin code during this upgrade.

### django-jsonfield

Version changes introduced a cast to string for returned values, breaking AWX code that assumes these fields are dictionaries. Upgrading requires refactoring to accommodate this change.

### wheel

azure-cli-core requires a specific `wheel` version incompatible with later pip versions. Override as necessary.

### pip and setuptools

Ensure offline installer functionality is confirmed before upgrading. Versions must match those used in the pip bootstrapping step in the top-level Makefile.

## Library Notes

### pexpect

Version 4.8 introduces changes to `searchwindowsize` that are slightly concerning. Pin to `pexpect==4.7.x` until further testing can be done with version 4.8.

### requests-futures

This library can be removed when a solution for external log queuing is ready, as per [this pull request](https://github.com/ansible/awx/pull/5092).

## Backlinks

- [AWX Docker Bootstrap Documentation](../README.md)
```

This improved Markdown document includes clear headings, proper structure, and additional metadata in the frontmatter. It also maintains all original information while enhancing readability for GitHub rendering.