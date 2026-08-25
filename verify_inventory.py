#!/usr/bin/env python

"""
Standalone script to ensure cross-environment inventory consistency,
group hierarchy alignment, and structural sanity across the
multi-environment data center configuration.

Key Capabilities:

- **Cross-Environment Linking:** Automatically manages and recreates
    relative symlinks for host files (*.yml), group variables
    (group_vars), and host variables (host_vars) across environments
    (e.g., PROD, QA, DEV).
- **Comment-Preserving Key Sorting:** Leverages Ruamel.YAML to sort
    keys within multi-environment mapping configurations while
    strictly preserving comments and structural formatting.
    This is essential in environments where comments/annotations in the
    inventory are considered first-class citizens.
- **Hierarchy Validation:** Validates that group definitions mapped
    across environment hosts match the global group hierarchy
    definition (xenv_groups.yml).
- **Mutual Exclusivity Checking:** Enforces business and architectural
    rules preventing hosts from incorrectly spanning multiple mutually
    exclusive group labels.
- **Pytest & JUnit Integration:** Wraps validation checks inside
    standard pytest routines, allowing report generation for CI/CD
    test reporting dashboards via --pytest (-p) or custom report
    XML paths (-r / --junitxml).
"""

from __future__ import absolute_import, annotations, division, print_function

__metaclass__ = type

import argparse
import importlib.metadata
import logging
import os
import re
import subprocess
import sys
from abc import ABC, ABCMeta, abstractmethod
from pathlib import Path
from typing import Any, Dict, Optional, Union

import yaml

# Try loading ruamel.yaml and pyyaml libraries
try:
    from ruamel.yaml import YAML
    from ruamel.yaml.comments import CommentedMap
except ImportError as imp_exc:
    YAML = CommentedMap = None
    YAML_RUAMEL_LIB_IMPORT_ERROR = imp_exc
else:
    YAML_RUAMEL_LIB_IMPORT_ERROR = None


CONFIG_YAML_DEFAULT = {
    "typ": "rt",
    "allow_duplicate_keys": None,
    "default_style": None,
    "default_flow_style": None,
    "encoding": None,
    "explicit_start": True,
    "explicit_end": False,
    "version": None,
    "tags": None,
    "canonical": None,
    "indent": None,
    "width": None,
    "allow_unicode": None,
    "line_break": None,
    "mapping": None,
    "sequence": None,
    "offset": None,
    "preserve_quotes": None,
}

__scriptName__ = os.path.basename(sys.argv[0])

# Setup logging formatting matching the expected styling
logging.basicConfig(
    level=logging.INFO, format="[%(levelname)-7s] %(name)s: %(message)s"
)
log = logging.getLogger(__scriptName__)

SCRIPT_VERSION = "2026.8.2"


def print_version():
    """Print script version, Python version, and essential library versions."""
    libs = ["ruamel.yaml", "ansible"]
    version_info = []

    for lib in libs:
        try:
            ver = importlib.metadata.version(lib)
            version_info.append(f"    {lib}: {ver}")
        except importlib.metadata.PackageNotFoundError:
            pass  # Gracefully skip if not installed in the environment

    print(f"{__scriptName__}")
    print(f"  version: {SCRIPT_VERSION}")
    print(f"  python version: {sys.version.split()[0]}")
    print("  python libraries:")
    if version_info:
        print("\n".join(version_info))
    else:
        print("    None found")


def get_project_root() -> Path:
    """Determine the project root using git, falling back to checking for the inventory subdirectory."""
    try:
        res = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )
        if res.returncode == 0 and res.stdout.strip():
            root_path = Path(res.stdout.strip())
            if (root_path / "inventory").is_dir():
                return root_path
    except Exception:
        pass

    # Fallback: check if current working directory or script directory contains an 'inventory' subdirectory
    candidate_paths = [Path.cwd(), Path(__file__).resolve().parent]
    for candidate in candidate_paths:
        if (candidate / "inventory").is_dir():
            return candidate

    raise RuntimeError(
        "Could not determine the project root: "
        "(1) 'git rev-parse --show-toplevel' failed or path is invalid, and "
        "(2) no 'inventory' directory was found in the current working "
        "directory or script directory."
    )


def load_runtime_config() -> dict:
    """Load configuration from a YAML file named after the script
    (e.g., .verify_inventory.yml) located at the project root."""
    try:
        project_dir = get_project_root()
    except Exception:
        project_dir = Path.cwd()

    script_stem = Path(__file__).stem
    config_filename = f".{script_stem}.yml"
    config_path = project_dir / config_filename

    default_config = {
        "exclusive_group_patterns": [
            r"docker_stack_env_(admin|dev|prod|qa)$",
            r"ca_domain_.*_(int_dettonville|int_johnson)$",
        ],
        "global_xenv_group_file": "xenv_groups.yml",
        "global_xenv_hosts_file": "xenv_hosts.yml",
        "envs": ["PROD", "QA", "DEV"],
        "inventory_yml_list": ["hosts.yml", "xenv_hosts.yml", "xenv_groups.yml"],
    }

    if config_path.exists():
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                user_config = yaml.safe_load(f) or {}
                if isinstance(user_config, dict):
                    default_config.update(user_config)
                    log.debug(f"Loaded runtime configuration from {config_path}")
        except Exception as e:
            log.warning(f"Failed to load config file {config_path}: {e}")

    return default_config


RUNTIME_CONFIG = load_runtime_config()
MUTUALLY_EXCLUSIVE_GROUP_PATTERNS = RUNTIME_CONFIG.get("exclusive_group_patterns", [])
ENVS = RUNTIME_CONFIG.get("envs", ["PROD", "QA", "DEV"])
INVENTORY_YML_LIST = RUNTIME_CONFIG.get(
    "inventory_yml_list", ["hosts.yml", "xenv_hosts.yml", "xenv_groups.yml"]
)
GLOBAL_XENV_GROUP_FILE = RUNTIME_CONFIG.get("global_xenv_group_file", "xenv_groups.yml")
GLOBAL_XENV_HOSTS_FILE = RUNTIME_CONFIG.get("global_xenv_hosts_file", "xenv_hosts.yml")


class MissingLibError(Exception):
    """Exception raised when a required library is missing."""

    def __init__(self, lib_name, msg):
        super().__init__(msg)
        self.lib_name = lib_name


class GitInventoryParserMeta(ABCMeta):
    """Custom metaclass handling potential metaclass conflicts."""

    pass


class GitInventoryParser(ABC, metaclass=GitInventoryParserMeta):
    """Abstract base class for YAML parsers."""

    def __init__(self, yaml_lib: str, yaml_config: Optional[Dict[str, Any]] = None):
        self.yaml_lib = yaml_lib
        self.yaml_config = yaml_config or CONFIG_YAML_DEFAULT

    @abstractmethod
    def load(self, yaml_content: Union[str, bytes]) -> Any:
        pass

    @abstractmethod
    def dump(self, data: Any) -> str:
        pass

    @abstractmethod
    def load_from_file(self, file_path: Union[str, Path]) -> Union[dict, list]:
        pass

    @abstractmethod
    def dump_to_file(self, data: Any, file_path: str) -> None:
        pass


# ref:
# https://stackoverflow.com/questions/47382227/python-yaml-update-preserving-order-and-comments
class RuamelYamlParser(GitInventoryParser):
    def __init__(self, yaml_config=None):
        # ref:
        # https://docs.ansible.com/ansible-core/devel/dev_guide/testing/sanity/import.html#import
        if YAML_RUAMEL_LIB_IMPORT_ERROR:
            # Needs: from ansible.module_utils.basic import
            # missing_required_lib
            raise MissingLibError(
                "ruamel.yaml", "python ruamel.yaml library is missing"
            ) from YAML_RUAMEL_LIB_IMPORT_ERROR

        self.yaml = YAML()
        # self.yaml = YAML(typ='rt')
        # self.yaml = YAML(typ='full')
        self.yaml_parser_type = "RuamelYaml"
        super().__init__(yaml_lib=self.yaml_parser_type, yaml_config=yaml_config)

        # Configure Ruamel.YAML based on provided config
        if "preserve_quotes" in self.yaml_config:
            self.yaml.preserve_quotes = self.yaml_config["preserve_quotes"]
        if "width" in self.yaml_config:
            self.yaml.width = self.yaml_config["width"]
        if "allow_duplicate_keys" in self.yaml_config:
            self.yaml.allow_duplicate_keys = self.yaml_config["allow_duplicate_keys"]
        if "explicit_start" in self.yaml_config:
            self.yaml.explicit_start = self.yaml_config["explicit_start"]
        # if "indent" in self.yaml_config:
        #     self.yaml.indent(mapping=self.yaml_config['indent'],
        #       sequence=self.yaml_config['indent'])

        self.yaml.indent(
            mapping=self.yaml_config.get("mapping", 2),
            sequence=self.yaml_config.get("sequence", 4),
            offset=self.yaml_config.get("offset", 2),
        )

        # https://yaml.readthedocs.io/en/latest/
        # ref: https://stackoverflow.com/questions/51316491/ruamel-yaml-clarification-on-typ-and-pure-true#51318354
        # ref: https://stackoverflow.com/questions/76331049/ruamel-yaml-anchors-with-roundtriploader-roundtripdumper
        # typ can be one of ['rt','safe','unsafe','base']
        if "typ" in self.yaml_config:
            self.yaml.typ = self.yaml_config["typ"]

        # ref: https://stackoverflow.com/questions/44313992/how-to-keep-null-value-in-yaml-file-while-dumping-though-ruamel-yaml # noqa: E501 url size exceeds 120
        # noinspection PyShadowingNames
        def my_represent_none(self_rep, data):
            return self_rep.represent_scalar("tag:yaml.org,2002:null", "null")

        # ref: https://stackoverflow.com/questions/44313992/how-to-keep-null-value-in-yaml-file-while-dumping-though-ruamel-yaml # noqa: E501 url size exceeds 120
        self.yaml.representer.add_representer(type(None), my_represent_none)
        # self.yaml.representer.add_representer(self.my_represent_none)

        # # Default to safe loading
        # self.yaml.default_flow_style = config.get('default_flow_style',
        #   False)

    def __str__(self):
        return "RuamelYamlParser(yaml_config=%s)" % self.yaml_config

    def load(self, yaml_content: Union[str, bytes]) -> Any:
        """Load YAML content using Ruamel.YAML."""
        try:
            from io import StringIO

            if isinstance(yaml_content, bytes):
                yaml_content = yaml_content.decode("utf-8")
            return self.yaml.load(StringIO(yaml_content))
        except Exception as e:
            # noinspection PyUnresolvedReferences
            raise yaml.YAMLError(f"Ruamel.YAML parsing error: {e}") from e

    def load_from_file(self, file_path: Union[str, Path]) -> Union[dict, list]:
        """Load YAML content from file using Ruamel.YAML."""
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                return self.yaml.load(file)
        except FileNotFoundError as e:
            raise FileNotFoundError(f"YAML file not found: {file_path}") from e
        except Exception as e:
            # noinspection PyUnresolvedReferences
            raise yaml.YAMLError(f"Ruamel.YAML file parsing error: {e}") from e

    # ref: https://pyyaml.org/wiki/PyYAMLDocumentation
    def dump(self, data: Any, stream: Optional[Any] = None) -> Optional[str]:
        """Serialize data to YAML string or write to stream using
        Ruamel.YAML."""
        try:
            if stream is not None:
                return self.yaml.dump(data, stream)
            from io import StringIO

            stream_io = StringIO()
            self.yaml.dump(data, stream_io)
            return stream_io.getvalue()
        except Exception as e:
            raise yaml.YAMLError(f"Ruamel.YAML serialization error: {e}") from e

    def dump_to_file(self, data: Any, file_path: str) -> None:
        """Write data to YAML file using Ruamel.YAML."""
        try:
            with open(file_path, "w", encoding="utf-8") as file:
                self.yaml.dump(data, file)
        except FileNotFoundError as e:
            raise FileNotFoundError(f"YAML file not found: {file_path}") from e
        except Exception as e:
            raise yaml.YAMLError(f"Ruamel.YAML file serialization error: {e}") from e

    ########################################
    # handle commented maps/dictionaries
    # ref: https://stackoverflow.com/questions/40226610/ruamel-yaml-equivalent-of-sort-keys#40227545
    # ref: https://stackoverflow.com/questions/49613901/sort-yaml-file-with-comments
    # ref: https://github.com/maxx27/pyyaml-sort/blob/main/comments_sort.py
    @staticmethod
    def recursive_sort(obj, level=0, reverse_sort=False):
        """Recursively sort dict keys (including CommentedMap) in-place while
        preserving comments and structure as much as possible.

        Uses pop + insert(0) on reverse-sorted keys so that the final order
        is ascending. This approach is more reliable for comment preservation
        than rebuilding comment attributes manually.
        """
        if isinstance(obj, dict):
            # Process children first
            for key in list(obj.keys()):
                # noinspection PyUnresolvedReferences
                __class__.recursive_sort(
                    obj[key], level=level + 1, reverse_sort=reverse_sort
                )
            # Now sort keys. For CommentedMap use insert to keep comment bindings.
            if isinstance(obj, CommentedMap):
                keys = sorted(list(obj.keys()), key=str, reverse=not reverse_sort)
                for key in keys:
                    value = obj.pop(key)
                    obj.insert(0, key, value)
            else:
                # Plain dict: rebuild sorted
                sorted_items = sorted(
                    obj.items(), key=lambda x: str(x[0]), reverse=reverse_sort
                )
                obj.clear()
                obj.update(sorted_items)
            return obj
        if isinstance(obj, list):
            for idx, elem in enumerate(obj):
                # noinspection PyUnresolvedReferences
                obj[idx] = __class__.recursive_sort(
                    elem, level=level + 1, reverse_sort=reverse_sort
                )
        return obj


# --- Autofix Functions ---


def create_host_links_yml(inventory_dir: Path, envs: list):
    log.debug("Creating host (*.yml) symlinks")
    for env in envs:
        env_dir = inventory_dir / env
        if not env_dir.exists():
            continue
        env_dir.mkdir(parents=True, exist_ok=True)

        # Remove existing symlinks for *.yml
        for symlink in env_dir.glob("*.yml"):
            if symlink.is_symlink():
                symlink.unlink()

        # Create relative symlinks back to inventory root yml files
        for yml_file in inventory_dir.glob("*.yml"):
            rel_path = os.path.relpath(yml_file, env_dir)
            target_link = env_dir / yml_file.name
            if target_link.exists() or target_link.is_symlink():
                target_link.unlink()
            target_link.symlink_to(rel_path)
    return 0


def create_groupvars_links_yml(inventory_dir: Path, envs: list):
    log.debug("Creating group_vars/*.yml symlinks")
    base_group_vars = inventory_dir / "group_vars"

    for env in envs:
        env_dir = inventory_dir / env
        if not env_dir.exists():
            continue
        env_group_vars = env_dir / "group_vars"
        env_group_vars.mkdir(parents=True, exist_ok=True)

        # Remove existing symlinks in group_vars
        for item in env_group_vars.iterdir():
            if item.is_symlink() or item.is_file() and item.name != "env_specific.yml":
                item.unlink()

        # Link parent group_vars/*.yml files
        if base_group_vars.exists():
            for yml_file in base_group_vars.glob("*.yml"):
                rel_path = os.path.relpath(yml_file, env_group_vars)
                target_link = env_group_vars / yml_file.name
                if target_link.exists() or target_link.is_symlink():
                    target_link.unlink()
                target_link.symlink_to(rel_path)

            # Link subdirectories excluding 'all'
            for sub_dir in base_group_vars.iterdir():
                if sub_dir.is_dir() and sub_dir.name != "all":
                    rel_path = os.path.relpath(sub_dir, env_group_vars)
                    target_link = env_group_vars / sub_dir.name
                    if target_link.is_symlink() or target_link.exists():
                        if target_link.is_symlink():
                            target_link.unlink()
                    if not target_link.exists():
                        target_link.symlink_to(rel_path)

        # Handle group_vars/all directory inside environment
        env_group_all = env_group_vars / "all"
        env_group_all.mkdir(parents=True, exist_ok=True)
        for item in env_group_all.iterdir():
            if item.is_symlink():
                item.unlink()

        parent_all_dir = base_group_vars / "all"
        if parent_all_dir.exists():
            for yml_file in parent_all_dir.glob("*.yml"):
                rel_path = os.path.relpath(yml_file, env_group_all)
                target_link = env_group_all / yml_file.name
                if target_link.exists() or target_link.is_symlink():
                    target_link.unlink()
                target_link.symlink_to(rel_path)

        # Ensure env_specific.yml placeholder exists inside group_vars/all/
        env_specific = env_group_all / "env_specific.yml"
        if not env_specific.exists():
            env_specific.touch()
    return 0


def create_hostvars_links_yml(inventory_dir: Path, envs: list):
    log.debug("Creating host_vars symlinks")
    base_host_vars = inventory_dir / "host_vars"
    for env in envs:
        env_dir = inventory_dir / env
        if not env_dir.exists():
            continue
        target_link = env_dir / "host_vars"
        if target_link.is_symlink() or target_link.exists():
            if target_link.is_symlink():
                target_link.unlink()
        if base_host_vars.exists() and not target_link.exists():
            rel_path = os.path.relpath(base_host_vars, env_dir)
            target_link.symlink_to(rel_path)
    return 0


def sort_xenv_files(inventory_dir: Path, file_list: list):
    """Sort keys in YAML files using the comment-preserving RuamelYamlParser."""
    parser = RuamelYamlParser(CONFIG_YAML_DEFAULT)
    for filename in file_list:
        for file_path in inventory_dir.rglob(filename):
            if file_path.is_file():
                try:
                    data = parser.load_from_file(file_path)
                    if data:
                        sorted_data = parser.recursive_sort(data)
                        parser.dump_to_file(sorted_data, file_path)
                    log.debug(f"Sorted keys for {file_path}")
                except Exception as e:
                    log.error(f"Failed to sort {file_path}: {e}")
                    return 1
    return 0


# --- Helper Functions for Validation Logic ---


def get_all_subkeys(input_dict: dict, key_list: list, parent_key: str = None):
    """Recursively finds all keys that are children of the specified parent keys."""
    if not isinstance(input_dict, dict):
        return
    for i, j in input_dict.items():
        if parent_key and parent_key in key_list:
            yield i
        if isinstance(j, dict):
            yield from get_all_subkeys(j, key_list, i)


def search_key_values(input_dict: dict, key: str):
    """Searches for a specific key in a nested dictionary and yields its values."""
    if not isinstance(input_dict, dict):
        return
    for i, j in input_dict.items():
        if i == key:
            yield j
        if isinstance(j, dict):
            yield from search_key_values(j, key)


def resolve_group_ancestry(hierarchy_dict):
    """Builds a child -> set(parents) map by walking the global group hierarchy structure."""
    ancestry = {}

    def walk(current_dict, parents):
        if not isinstance(current_dict, dict):
            return
        children = current_dict.get("children", {})
        if not children:
            return
        for child_name, child_content in children.items():
            if child_name not in ancestry:
                ancestry[child_name] = set()
            ancestry[child_name].update(parents)
            walk(child_content, parents + [child_name])

    all_content = hierarchy_dict.get("all", {})
    walk(all_content, ["all"])
    return ancestry


# --- Validation Test Functions ---


def verify_file_extensions(inventory_dir: Path) -> tuple[int, list[str]]:
    log.debug("Verify all files consistent with *.yml")
    allowed_extensions = {".yml", ".sh", ".py", ".log", ".md", ""}
    ignored_dirs = {".test-results", "__pycache__", ".pytest_cache", ".git"}

    exception_files = []
    error_messages = []
    for root, dirs, files in os.walk(inventory_dir):
        dirs[:] = [d for d in dirs if d not in ignored_dirs]
        for file in files:
            p = Path(root) / file
            if file.startswith("."):
                continue
            if p.suffix not in allowed_extensions and file != "pytest.ini":
                exception_files.append(p)

    if not exception_files:
        return 0, []
    else:
        msg = f"There are [{len(exception_files)}] inconsistent file names found:"
        error_messages.append(msg)
        for f in exception_files:
            error_messages.append(f"  Inconsistent extension file: {f}")
        return len(exception_files), error_messages


def verify_yml_sortorder(inventory_dir: Path) -> tuple[int, list[str]]:
    error_count = 0
    error_messages = []
    for filename in INVENTORY_YML_LIST:
        for file_path in inventory_dir.rglob(filename):
            if file_path.is_file():
                try:
                    with open(file_path, "r") as f:
                        content = f.read()
                    data = yaml.safe_load(content)
                    sorted_content = yaml.dump(data, sort_keys=True, indent=2)
                    current_normalized = yaml.dump(data, sort_keys=False, indent=2)

                    if current_normalized.strip() != sorted_content.strip():
                        error_messages.append(f"===> Sort diff found in {file_path}")
                        error_count += 1
                except Exception as e:
                    error_messages.append(
                        f"Error parsing {file_path} for sort validation: {e}"
                    )
                    error_count += 1
    return error_count, error_messages


def verify_xenv_group_hierarchy(inventory_dir: Path) -> tuple[int, list[str]]:
    error_count = 0
    error_messages = []
    xenv_groups_path = inventory_dir / GLOBAL_XENV_GROUP_FILE

    if not xenv_groups_path.exists():
        msg = f"Missing required group hierarchy file: {xenv_groups_path}"
        return 1, [msg]

    with open(xenv_groups_path) as f:
        groups_dict = yaml.safe_load(f) or {}

    def check_groups_in_file(file_path: Path, context_label: str):
        nonlocal error_count
        if not file_path.exists():
            return
        with open(file_path) as f:
            file_dict = yaml.safe_load(f) or {}

        children_groups = list(get_all_subkeys(file_dict, ["children"]))
        for group in children_groups:
            key_value_list = list(search_key_values(groups_dict, group))
            if not key_value_list:
                error_messages.append(
                    f"Hierarchy Mismatch in {context_label}: Group [{group}] "
                    f"is missing from global {GLOBAL_XENV_GROUP_FILE} "
                    f"definition."
                )
                error_count += 1

    # Check per-environment hosts.yml files
    for env in ENVS:
        env_hosts = inventory_dir / env / "hosts.yml"
        check_groups_in_file(env_hosts, f"{env}/hosts.yml")

    # Check top-level xenv_hosts.yml file (symlinked across environments)
    xenv_hosts_path = inventory_dir / GLOBAL_XENV_HOSTS_FILE
    check_groups_in_file(xenv_hosts_path, GLOBAL_XENV_HOSTS_FILE)

    return error_count, error_messages


def verify_child_inventories(inventory_dir: Path) -> tuple[int, list[str]]:
    error_count = 0
    error_messages = []
    for env in ENVS:
        env_path = inventory_dir / env
        if env_path.exists():
            res = subprocess.run(
                ["ansible-inventory", "--graph", "-i", str(env_path)],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
            )
            if (
                res.returncode != 0
                or "error" in res.stdout.lower()
                or "warning" in res.stdout.lower()
            ):
                error_messages.append(
                    f"Ansible inventory graph validation failed for environment '{env}':\n{res.stdout.strip()}"
                )
                error_count += 1
    return error_count, error_messages


def verify_child_groupvars(inventory_dir: Path) -> tuple[int, list[str]]:
    error_count = 0
    error_messages = []
    base_gv = inventory_dir / "group_vars"
    for env in ENVS:
        env_gv = inventory_dir / env / "group_vars"
        if base_gv.exists() and env_gv.exists():
            # Simple check comparing items excluding env_specific.yml
            base_files = {f.name for f in base_gv.glob("*.yml")}
            env_files = {
                f.name for f in env_gv.glob("*.yml") if f.name != "env_specific.yml"
            }
            missing_files = base_files - env_files
            if missing_files:
                error_messages.append(
                    f"Group var mismatch in {env}/group_vars: Missing expected files from base group_vars -> {list(missing_files)}"
                )
                error_count += 1
    return error_count, error_messages


def verify_host_mutual_exclusive_group_labels(
    inventory_dir: Path,
) -> tuple[int, list[str]]:
    error_count = 0
    error_messages = []
    groups_file_path = inventory_dir / GLOBAL_XENV_GROUP_FILE

    if not groups_file_path.exists():
        return 1, [f"Missing required global groups file: {groups_file_path}"]

    with open(groups_file_path) as f:
        global_groups = yaml.safe_load(f) or {}

    group_ancestry = resolve_group_ancestry(global_groups)
    regex_list = [re.compile(p) for p in MUTUALLY_EXCLUSIVE_GROUP_PATTERNS]

    for env in ENVS:
        hosts_file = inventory_dir / env / "hosts.yml"
        if hosts_file.exists():
            with open(hosts_file) as f:
                hosts_inventory = yaml.safe_load(f) or {}

            host_to_full_groups = {}
            inventory_groups = hosts_inventory.get("all", {}).get("children", {})
            for group_name, group_content in inventory_groups.items():
                content = group_content if group_content else {}
                hosts_in_group = content.get("hosts", {})
                if hosts_in_group is None:
                    hosts_in_group = {}

                for host in hosts_in_group.keys():
                    if host not in host_to_full_groups:
                        host_to_full_groups[host] = set()
                    host_to_full_groups[host].add(group_name)
                    if group_name in group_ancestry:
                        host_to_full_groups[host].update(group_ancestry[group_name])

            host_group_label_mapping = {}
            for host, resolved_groups in host_to_full_groups.items():
                for group_name in resolved_groups:
                    for regex in regex_list:
                        match = regex.match(group_name)
                        if match:
                            group_label = (
                                match.group(1) if match.groups() else match.group(0)
                            )
                            if host not in host_group_label_mapping:
                                host_group_label_mapping[host] = {}
                            if group_label not in host_group_label_mapping[host]:
                                host_group_label_mapping[host][group_label] = set()
                            host_group_label_mapping[host][group_label].add(group_name)

            for host, envs_map in host_group_label_mapping.items():
                if len(envs_map) > 1:
                    details = ", ".join(
                        ["%s %s" % (label, list(gs)) for label, gs in envs_map.items()]
                    )
                    error_messages.append(
                        f"Host mutual exclusivity check failed for environment '{env}' using {hosts_file.name}:\n"
                        f"Host [{host}] spans multiple mutually exclusive group labels: {details}"
                    )
                    error_count += 1

    return error_count, error_messages


# --- CLI Routing & JUnit Pytest Execution ---


def cmd_autofix(args):
    project_dir = get_project_root()
    inventory_dir = project_dir / "inventory"
    os.chdir(inventory_dir)

    log.debug(f"==> PROJECT_DIR={project_dir}")
    log.debug(f"==> INVENTORY_DIR={inventory_dir}")

    create_host_links_yml(inventory_dir, ENVS)
    create_groupvars_links_yml(inventory_dir, ENVS)
    create_hostvars_links_yml(inventory_dir, ENVS)
    sort_xenv_files(inventory_dir, INVENTORY_YML_LIST)
    log.info("Autofix completed successfully!")


def run_pytests(
    test_cases: Optional[list] = None, junit_xml_path: Optional[str] = None
) -> int:
    """Conditionally execute pytest to generate JUnit XML reports for pipelines."""
    try:
        import pytest
    except ImportError:
        log.error(
            "pytest library is required for running tests with JUnit reporting (-r/--pytest option)."
        )
        return 1

    script_self = Path(__file__).resolve()

    pytest_args = [str(script_self)]
    if junit_xml_path:
        pytest_args.extend(["--junitxml", junit_xml_path])

    log.info(f"Running pytest wrapper suite with args: {pytest_args}")
    return pytest.main(pytest_args)


def cmd_test(args):
    project_dir = get_project_root()
    inventory_dir = project_dir / "inventory"

    # Capture any user-specified JUnit path before changing working directories
    raw_junit_path = (
        getattr(args, "junit_xml", None)
        or getattr(args, "junit_report", None)
    )

    if (
        getattr(args, "pytest_mode", False)
        or raw_junit_path
    ):
        if raw_junit_path:
            # Resolve relative paths against project_dir instead of inventory_dir
            junit_path = Path(raw_junit_path)
            if not junit_path.is_absolute():
                junit_path = project_dir / junit_path
        else:
            junit_path = project_dir / ".test-results" / "junit-inventory-report.xml"

        Path(junit_path).parent.mkdir(parents=True, exist_ok=True)

        # Change directory for test execution after resolving paths
        os.chdir(inventory_dir)
        log.debug(f"==> PROJECT_DIR={project_dir}")
        log.debug(f"==> INVENTORY_DIR={inventory_dir}")

        return run_pytests(
            test_cases=getattr(args, "test_cases", None),
            junit_xml_path=str(junit_path)
        )

    os.chdir(inventory_dir)
    log.debug(f"==> PROJECT_DIR={project_dir}")
    log.debug(f"==> INVENTORY_DIR={inventory_dir}")

    tests = {
        "verify_file_extensions": lambda: verify_file_extensions(inventory_dir),
        "verify_yml_sortorder": lambda: verify_yml_sortorder(inventory_dir),
        "verify_xenv_group_hierarchy": lambda: verify_xenv_group_hierarchy(
            inventory_dir
        ),
        "verify_child_inventories": lambda: verify_child_inventories(inventory_dir),
        "verify_child_groupvars": lambda: verify_child_groupvars(inventory_dir),
        "verify_host_mutual_exclusive_group_labels": lambda: verify_host_mutual_exclusive_group_labels(
            inventory_dir
        ),
    }

    total_failed = 0
    test_cases = getattr(args, "test_cases", None)
    selected_tests = test_cases if test_cases else tests.keys()

    log.info("=========== VERIFY START ==========")
    for test_name in selected_tests:
        if test_name in tests:
            log.debug(f"Running test case: {test_name}")
            code, errors = tests[test_name]()
            if code == 0:
                log.info(f"[SUCCESS] test_case: {test_name}: SUCCESS")
            else:
                log.error(f"[FAILED] test_case: {test_name}: FAILED (Errors: {code})")
                for err in errors:
                    print(err)
                total_failed += code
        else:
            log.warning(f"Unknown test case: {test_name}")

    log.info("============ VERIFY END ===========")
    log.info("OVERALL INVENTORY TEST RESULTS")
    log.info(f"TOTAL FAILED={total_failed}")
    if total_failed == 0:
        log.info("TEST SUCCEEDED!")
        return 0
    else:
        log.error("TEST FAILED!")
        return total_failed


# --- Pytest Integration Hooks (when executed via pytest) ---


def pytest_generate_tests(metafunc):
    if "test_case" in metafunc.fixturenames:
        tests_list = [
            "verify_file_extensions",
            "verify_yml_sortorder",
            "verify_xenv_group_hierarchy",
            "verify_child_inventories",
            "verify_child_groupvars",
            "verify_host_mutual_exclusive_group_labels",
        ]
        metafunc.parametrize("test_case", tests_list)


def test_inventory(test_case):
    """Pytest test function executed dynamically for each inventory check when invoked via pytest."""
    project_dir = get_project_root()
    inventory_dir = project_dir / "inventory"

    tests = {
        "verify_file_extensions": lambda: verify_file_extensions(inventory_dir),
        "verify_yml_sortorder": lambda: verify_yml_sortorder(inventory_dir),
        "verify_xenv_group_hierarchy": lambda: verify_xenv_group_hierarchy(
            inventory_dir
        ),
        "verify_child_inventories": lambda: verify_child_inventories(inventory_dir),
        "verify_child_groupvars": lambda: verify_child_groupvars(inventory_dir),
        "verify_host_mutual_exclusive_group_labels": lambda: verify_host_mutual_exclusive_group_labels(
            inventory_dir
        ),
    }

    if test_case in tests:
        code, errors = tests[test_case]()
        if code != 0:
            for err in errors:
                print(err, file=sys.stderr)
        assert code == 0, f"Test case '{test_case}' failed with {code} error(s)."


class CustomArgumentParser(argparse.ArgumentParser):
    """Custom ArgumentParser to append usage examples mirroring the original bash script."""

    def format_help(self):
        help_text = super().format_help()
        script_name = Path(sys.argv[0]).name
        examples_text = f"""
Examples:
       {script_name} 
       {script_name} test verify_file_extensions
       {script_name} test verify_yml_sortorder
       {script_name} test -p
       {script_name} test -p verify_file_extensions
       {script_name} test -r .test-results/junit-report.xml
       {script_name} autofix
       {script_name} -v
"""
        return help_text + examples_text


def main():
    parser = CustomArgumentParser(
        description=f"""
        Standalone script to ensure cross-environment inventory consistency,
        group hierarchy alignment, and structural sanity across the 
        multi-environment data center configuration.

        Version: {SCRIPT_VERSION}
        
        Key Capabilities:
        
        - **Cross-Environment Linking:** Automatically manages and recreates
            relative symlinks for host files (*.yml), group variables
            (group_vars), and host variables (host_vars) across environments
            (e.g., PROD, QA, DEV).
        - **Comment-Preserving Key Sorting:** Leverages Ruamel.YAML to sort
            keys within multi-environment mapping configurations while
            strictly preserving comments and structural formatting.
            This is essential in environments where comments/annotations in the
            inventory are considered first-class citizens.
        - **Hierarchy Validation:** Validates that group definitions mapped
            across environment hosts match the global group hierarchy
            definition (xenv_groups.yml).
        - **Mutual Exclusivity Checking:** Enforces business and architectural
            rules preventing hosts from incorrectly spanning multiple mutually
            exclusive group labels.
        - **Pytest & JUnit Integration:** Wraps validation checks inside
            standard pytest routines, allowing report generation for CI/CD
            test reporting dashboards via --pytest (-p) or custom report
            XML paths (-r / --junitxml).""",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable verbose debug logging"
    )
    parser.add_argument(
        "-V",
        "--version",
        action="store_true",
        help="Show program's version number and exit"
    )

    subparsers = parser.add_subparsers(dest="command")

    # Autofix parser
    subparsers.add_parser(
        "autofix", help="Autofix cross-environment links and sort inventory files"
    )

    # Test parser
    test_parser = subparsers.add_parser(
        "test", help="Run inventory validation test suite"
    )
    test_parser.add_argument(
        "-p",
        "--pytest",
        action="store_true",
        dest="pytest_mode",
        help="Run tests via pytest with JUnit reporting support",
    )
    test_parser.add_argument(
        "-r",
        "--junit-report",
        dest="junit_report",
        metavar="PYTEST_JUNIT_REPORT",
        help="Use specified junitxml path for pytest report",
    )
    test_parser.add_argument(
        "--junitxml",
        dest="junit_xml",
        metavar="FILE",
        help="Generate JUnit XML report file path",
    )
    test_parser.add_argument(
        "test_cases", nargs="*", help="Specific test cases to execute"
    )

    args = parser.parse_args()

    if args.version:
        print_version()
        sys.exit(0)

    # Configure Logging level dynamically
    log_level = logging.DEBUG if args.verbose else logging.INFO
    log.setLevel(log_level)
    log.debug(f"Starting with log level: {log_level}")

    if args.command == "autofix":
        cmd_autofix(args)
    elif args.command == "test":
        sys.exit(cmd_test(args))
    else:
        # Default behavior when no subcommand is specified: run 'autofix' followed by 'test'
        log.info("No command specified. Running 'autofix' followed by 'test'...")
        cmd_autofix(args)
        exit_code = cmd_test(args)
        sys.exit(exit_code)


if __name__ == "__main__":
    main()
