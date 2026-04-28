
# Contributing to ansible-datacenter

Thank you for contributing to the `ansible-datacenter` project. Adhering to these guidelines ensures our automation infrastructure remains stable, secure, and scalable.

## Table of Contents
* [Code Standards & Linting](#code-standards--linting)
* [Development Best Practices](#development-best-practices)
* [Testing Requirements](#testing-requirements)
* [Documentation Requirements](#documentation-requirements)
* [Pull Request & Review Process](#pull-request--review-process)
* [Code of Conduct](#code-of-conduct)
* [Support & Contact](#support--contact)

---

## Code Standards & Linting

All contributions must pass our automated linting suite to maintain codebase consistency.

### Ansible Lint
All YAML files must be compliant with `ansible-lint`. Run this locally via:
```bash
ansible-lint .
```
* Use native Ansible modules over `shell` or `command` whenever possible.
* Every task must have a descriptive `name` attribute.

### Python Code
For custom modules or pipeline scripts, follow PEP 8 standards. Use `flake8` or `black` for formatting.

---

## Development Best Practices

### Logic Scoping & Git Integrity
* **Strict Logic Scoping:** Ensure that logic intended for specific environments or scripts (e.g., custom Git ignore checks or PyCharm macro workarounds) is scoped correctly to avoid side effects on unrelated scripts or the broader repository.
* **Secret Management:** Never commit raw secrets. Use `ansible-vault` for any sensitive variables.
* **Idempotency:** Roles must be designed so that multiple executions do not change the system state after the initial configuration.

---

## Testing Requirements

We use **Molecule** for multi-platform validation (Ubuntu, Debian, CentOS).

### Molecule Tests
Every new role **MUST** include a `molecule/` directory with at least a `default` scenario.
1. **Converge:** Ensure the `converge.yml` playbook runs without error.
2. **Idempotency:** The role must be idempotent (the second run must result in `changed=0`).
3. **Verify:** Use `verify.yml` or specialized testinfra/ansible verifiers to confirm the state of the system.

To run tests locally:
```bash
molecule test -s <scenario_name>
```

### CI Integration
Your contribution will be automatically tested via **GitHub Actions**. Ensure the "Verify All Green" workflow passes before requesting a review.

---

## Documentation Requirements

As part of our automated **wiki-pipeline**, documentation is generated directly from role metadata.

1. **README.md:** Each role must have its own `README.md` following the standard Ansible Galaxy format.
2. **Mermaid Diagrams:** For complex logic or workflows, include Mermaid diagrams within the documentation.
3. **Metadata:** Ensure `meta/main.yml` includes correct platform support, categories, and dependencies.

---

## Pull Request Process

1. **Branching:** Create a feature branch from `main`.
2. **Testing:** Confirm all Molecule tests pass locally.
3. **Vault:** Do not commit any raw secrets. Use `ansible-vault` for sensitive data.
4. **CI Validation:** Ensure the GitHub Actions "Verify All Green" workflow passes.
5. **Review:** Once the PR is submitted with green GitHub Actions CI status, tag Lee James Johnson for a final architectural review.
    * **What to expect:** We check for alignment with the **Dettonville Platform Architecture**, role modularity, and security compliance (Vault usage/KICS results).
    * **Timeline:** Reviews are typically completed within 2–3 business days.

---

## Code of Conduct

We are committed to a welcoming and inclusive environment. All contributors are expected to:
* Be respectful of differing viewpoints and experiences.
* Gracefully accept constructive criticism.
* Focus on what is best for the community and the stability of the platform.

---

## Support & Contact

For technical assistance or architectural queries, please reach out via:
* **Email:** [lee.johnson@dettonville.com](mailto:lee.johnson@dettonville.com)
* **Professional Network:** [LinkedIn](https://www.linkedin.com/in/leejjohnson/)
* **Issues:** Open a ticket in the GitHub Issues tab for bug reports or feature requests.

---

## Backlinks
- [README.md](README.md)
