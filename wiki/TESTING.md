```markdown
---
title: Testing Documentation
original_path: TESTING.md
category: Development
tags: [testing, linting, molecule, automation]
---

# Testing Documentation

This repository employs a multi-layered testing strategy, ranging from static analysis (linting) to dynamic infrastructure testing via Molecule.

## Table of Contents
- [Lint Testing](#lint-testing)
- [Automation Scripts](#automation-scripts)
- [Environment Setup](#prepare-collection-test-environment)
- [Molecule Functional Testing](#run-molecule-tests)
- [IDE & Tooling Consistency](#ide--tooling-consistency)

---

## Lint Testing

We use several static analysis tools to ensure code quality, security, and inclusivity.

- **Ansible-Lint:** Checks playbooks for practices that could potentially be improved.
- **YAMLlint:** Validates YAML syntax and formatting consistency.
- **KICS (Keeping Infrastructure as Code Secure):** An open-source static analysis tool used to find security vulnerabilities, compliance issues, and infrastructure misconfigurations.

### Manual Execution
```shell
# Run individual lints
ansible-lint -p
yamllint .
kics scan --ci --config .kics-config.yml
```

---

## Automation Scripts

To streamline the development workflow, two primary wrapper scripts are provided:

### 1. `run-lint-tests.sh`
This script serves as a unified entry point for all static analysis. It handles:
- **Dependency Management:** Automatically detects and installs missing tools (`jq`, `kics`, etc.) based on your OS (macOS, Linux, or MSYS2).
- **Logging:** Supports granular logging levels (`-L DEBUG`, `INFO`, etc.) to troubleshoot linting failures.
- **Execution:** Runs the full suite of lints (`ansible-lint`, `yamllint`, and `kics`) in sequence.

```shell
# List all available lint test cases
./run-lint-tests.sh -l

# Run all tests with debug logging
./run-lint-tests.sh -L DEBUG
```

### 2. `runme.sh`
This is the primary execution wrapper for running playbooks against real or test environments from the command line.
- **Environment Orchestration:** Sets up the `ANSIBLE_COLLECTIONS_PATH` and manages temporary variables.
- **Security:** Automatically initializes an SSH agent and securely extracts your `ansible_ssh_private_key` from the encrypted Vault.
- **Galaxy Management:** Can be configured to force-install or upgrade Galaxy collections via flags.

```shell
# Execute a specific playbook
./runme.sh site.yml -t bootstrap-ntp -l testgroup_lnx
```

---

## Prepare Collection Test Environment

### Why Use Symbolic Links?
In a modular Ansible architecture, roles often depend on external inventories or shared collections. Creating symbolic links allows you to:
- **Facilitate Local Testing:** Points the project to your local `tower-inventory` without duplicating data.
- **Synchronized Development:** Ensures that any changes made to shared collections are immediately reflected in your test runs without requiring a re-install via `ansible-galaxy`.

### Configuration
Ensure the `tower-inventory` repo is adjacent to this project in your local directory structure:

```shell
# Navigate to the tests directory
cd ~/repos/ansible/ansible-datacenter/tests

# Link the development inventory to facilitate local execution
ln -s ../inventory/DEV inventory
```

---

## Run Molecule Tests

### What is Molecule?

Molecule is a testing framework designed to aid in the development and testing of Ansible roles. It automatically provisions isolated Docker containers (using systemd-enabled images), executes your roles (`converge`), verifies the system state, and then tears down the environment. This ensures your roles work across multiple OS platforms (Ubuntu, CentOS, Debian) before they reach production.

### Execution Pattern
The `tests/molecule_exec.sh` wrapper manages the `MOLECULE_IMAGE_LABEL` to simplify testing across platforms.

| Task                  | Command Example                                               |
|:----------------------|:--------------------------------------------------------------|
| **Standard Test**     | `tests/molecule_exec.sh centos9 converge`                     |
| **Specific Scenario** | `tests/molecule_exec.sh ubuntu2404 converge -s bootstrap_pip` |
| **Debug Mode**        | `tests/molecule_exec.sh centos9 --debug converge`             |
| **Manual Inspection** | `tests/molecule_exec.sh redhat8 login`                        |
| **Cleanup**           | `molecule destroy --all`                                      |

---

## IDE & Tooling Consistency

### Pathing and Macros
When using an IDE to trigger these tests (e.g., via External Tools or Run Configurations), ensure your environment variables and content root macros are correctly aligned with the project structure.

- **PyCharm Users:** Be advised that the **PyCharm 2026** IDE has updated the behavior of the `$ContentRoot$` macro. Ensure your external tool paths are updated to account for this change to prevent "file not found" errors during script execution.
- **VS Code Users:** Ensure your `terminal.integrated.env` includes the correct `PYTHONPATH` and `ANSIBLE_COLLECTIONS_PATH` to match the symbolic links created in the [Environment Setup](#prepare-collection-test-environment).

---

## Backlinks
- [Main Documentation](README.md)
```

This improved version maintains all original information while adhering to clean, professional Markdown standards suitable for GitHub rendering.