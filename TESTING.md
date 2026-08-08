
# Testing Documentation

This repository employs a multi-layered testing strategy, ranging from static analysis (linting) to dynamic infrastructure testing via Molecule.

## Table of Contents

- [Inventory Verification](#inventory-verification-verify_inventorypy)
- [Lint Testing](#lint-testing)
- [Pre-commit hooks](#pre-commit-hooks)
- [Automation Scripts](#automation-scripts)
- [Environment Setup](#prepare-collection-test-environment)
- [Molecule Functional Testing](#run-molecule-tests)

---

## Inventory Verification (`verify_inventory.py`)

To ensure cross-environment inventory consistency, group hierarchy alignment, and structural sanity across the multi-environment data center configuration, the repository provides a standalone management tool: [`verify_inventory.py`](verify_inventory.py).

This script is designed for both local developer troubleshooting and automated execution within CI pipelines or pre-commit hooks.

### Key Capabilities

- **Cross-Environment Linking:** Automatically manages and recreates relative symlinks for host files (`*.yml`), group variables (`group_vars`), and host variables (`host_vars`) across environments (e.g., `PROD`, `QA`, `DEV`).
- **Comment-Preserving Key Sorting:** Leverages `Ruamel.YAML` to sort keys within multi-environment mapping configurations while strictly preserving comments and structural formatting. This is essential in environments where comments/annotations in the inventory are considered first-class citizens.
- **Hierarchy Validation:** Validates that group definitions mapped across environment hosts match the global group hierarchy definition (`xenv_groups.yml`).
- **Mutual Exclusivity Checking:** Enforces business and architectural rules preventing hosts from incorrectly spanning multiple mutually exclusive group labels.
- **Pytest & JUnit Integration:** Wraps validation checks inside standard pytest routines, allowing report generation for CI/CD test reporting dashboards via `--pytest` (`-p`) or custom report XML paths (`-r` / `--junitxml`).

### Manual Execution & Usage Examples

You can run individual verification modules, trigger automatic maintenance fixes, or execute tests via pytest directly from the command line:

```shell
# Run autofix to sync symlinks and sort keys
python3 verify_inventory.py autofix

# Execute the entire inventory validation test suite directly
python3 verify_inventory.py test

# Run a specific verification check case
python3 verify_inventory.py test verify_file_extensions
python3 verify_inventory.py test verify_yml_sortorder

# Run checks via pytest framework wrapper with JUnit XML reporting
python3 verify_inventory.py test -p
python3 verify_inventory.py test -r .test-results/junit-inventory-report.xml
```

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

## Pre-commit hooks

Git requires the hook scripts to be explicitly written into the repository's `.git/hooks/` directory.

### How to Set Up

1. **Navigate to the repository root**:
```bash
cd path/to/ansible-datacenter
```

2. **Install the git hook scripts**:
Run the following command to register pre-commit into your local `.git/hooks/` directory:
```bash
pre-commit install
## or specify hook types
pre-commit install --hook-type pre-commit
pre-commit install --hook-type pre-push
```


3. **Verify it works**:
You can manually test that the hooks fire across all files without needing to make a commit:
```bash
pre-commit run --all-files
```

### Additional Things to Check If It Fails:

* **Global hooks path:** If you use a custom global hooks template path via `git config --global core.hooksPath`, ensure it isn't intercepting or overriding local repository hooks.
* **Commit flags:** Ensure you aren't accidentally passing `--no-verify` (or `-n`), which explicitly tells git to skip the pre-commit hook execution.

Run the following commands to clear the cache and verify the environment:
```shell
pre-commit clean
pre-commit run --all-files
## or just a specified test
pre-commit run yamllint --all-files
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

### 2. `run-playbook.sh`
This is the primary execution wrapper for running playbooks against real or test environments from the command line.
- **Environment Orchestration:** Sets up the `ANSIBLE_COLLECTIONS_PATH` and manages temporary variables.
- **Security:** Automatically initializes an SSH agent and securely extracts your `ansible_ssh_private_key` from the encrypted Vault.
- **Galaxy Management:** Can be configured to force-install or upgrade Galaxy collections via flags.

```shell
# Execute a specific playbook
./run-playbook.sh site.yml -t bootstrap-ntp -l testgroup_lnx
```

---

## Prepare Collection Test Environment

### Why use Symbolic Links?
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
