---
name: Ansible Best Practices
globs: ["**/*.{yml,yaml,j2,py}"]
alwaysApply: true
description: Core standards for Ansible roles
---

# Ansible Best Practices

- Always use FQCNs unless inside the same collection
- Prefer `ansible.builtin` and official collections
- Ensure full idempotency in all tasks and modules
- Use `changed_when`, `failed_when`, and `register` for clarity
- Document all public modules, filters, and plugins
- Maintain high test coverage (molecule)
- For python: follow PEP 8 style, use type hints, prefer `pathlib` over `os.path`.
- "Always follow DRY (Don't Repeat Yourself) principles."
- "Use `test-driven-development` (`TDD`) approach."
