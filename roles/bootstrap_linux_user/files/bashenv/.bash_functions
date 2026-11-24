log_prefix_functions=".bash_functions:"

echo "${log_prefix_functions} configuring shell functions..."

## Initialize pyenv ONLY if it hasn't been set up yet (e.g., non-interactive PyCharm subshells)
#if [ -d "${HOME}/.pyenv" ]; then
#  export PYENV_ROOT="${HOME}/.pyenv"
#
#  # Only prepend to PATH if it's not already in PATH
#  case ":${PATH}:" in
#    *":${PYENV_ROOT}/shims:"*) ;;
#    *)
#      echo "${log_prefix_functions} Path updated for PYENV_ROOT [${PYENV_ROOT}]: ${PATH}"
#      export PATH="${PYENV_ROOT}/shims:${PATH}"
#      ;;
#  esac
#
#  case ":${PATH}:" in
#    *":${PYENV_ROOT}/bin:"*) ;;
#    *)
#      echo "${log_prefix_functions} Path updated for PYENV_ROOT [${PYENV_ROOT}]: ${PATH}"
#      export PATH="${PYENV_ROOT}/bin:${PATH}" ;;
#  esac
#
#  if command -v pyenv >/dev/null 2>&1; then
#    eval "$(pyenv init -)"
#  fi
#fi
#if [ -d "${HOME}/.pyenv" ]; then
#  export PYENV_ROOT="${HOME}/.pyenv"
#  export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
#  echo "${log_prefix_functions} Path updated for PYENV_ROOT [${PYENV_ROOT}]: ${PATH}"
#  if command -v pyenv >/dev/null 2>&1; then
#    eval "$(pyenv init -)"
#  fi
#fi

unalias ansible_debug_variable 1>/dev/null 2>&1 || true
unset -f ansible_debug_variable || true
function ansible_debug_variable() {
    local ANSIBLE_INVENTORY_HOST=${1:-"control01"}
    local ANSIBLE_VARIABLE_NAME=${2:-"group_names"}

    local RUN_ANSIBLE_COMMAND_ARRAY=()
    RUN_ANSIBLE_COMMAND_ARRAY+=("ansible")
    if [ -f "${ANSIBLE_DATACENTER_REPO}/.vault_pass" ]; then
        RUN_ANSIBLE_COMMAND_ARRAY+=("--vault-password-file ${ANSIBLE_DATACENTER_REPO}/.vault_pass")
    elif [ -f "${HOME}/.vault_pass" ]; then
        RUN_ANSIBLE_COMMAND_ARRAY+=("--vault-password-file ${HOME}/.vault_pass")
    fi
    RUN_ANSIBLE_COMMAND_ARRAY+=("-e @${ANSIBLE_DATACENTER_REPO}/vars/vault.yml")
    if [ -f "${ANSIBLE_DATACENTER_REPO}/vars/test-vars.yml" ]; then
        RUN_ANSIBLE_COMMAND_ARRAY+=("-e @${ANSIBLE_DATACENTER_REPO}/vars/test-vars.yml")
    fi
    RUN_ANSIBLE_COMMAND_ARRAY+=("-i ${ANSIBLE_INVENTORY_DIR}")
    RUN_ANSIBLE_COMMAND_ARRAY+=("-m debug")
    RUN_ANSIBLE_COMMAND_ARRAY+=("-a var=\"${ANSIBLE_VARIABLE_NAME}\"")
    RUN_ANSIBLE_COMMAND_ARRAY+=("${ANSIBLE_INVENTORY_HOST}")

    local RUN_ANSIBLE_COMMAND="${RUN_ANSIBLE_COMMAND_ARRAY[*]}"

    echo "${RUN_ANSIBLE_COMMAND}"
    eval "${RUN_ANSIBLE_COMMAND}"
    #  ansible -e @"${ANSIBLE_DATACENTER_REPO}/test-vars.yml" \
    #    -e @"${ANSIBLE_DATACENTER_REPO}/vars/vault.yml" \
    #    --vault-password-file "${ANSIBLE_DATACENTER_REPO}/.vault_pass" \
    #    -i "${ANSIBLE_INVENTORY_DIR}" \
    #    -m debug \
    #    -a "var=${ANSIBLE_VARIABLE_NAME}"
}

# Function to create an Ansible role from a single combined file
#
# Arguments:
#   $1: Path to the downloaded role file (e.g., ~/the_role_file_you_provided.txt)
#       This file is expected to contain content for tasks/main.yml,
#       defaults/main.yml, meta/main.yml, and handlers/main.yml,
#       delimited by lines like '^# FILE: <path>'.
#   $2: Path to the specified role target location (e.g., roles/prepare_kubernetes)
#       This is the directory where the new role will be created.
#
# Usage Example:
#   explode_ansible_role /path/to/my_combined_role_file.txt /path/to/ansible/roles/prepare_kubernetes
unalias explode_ansible_role 1>/dev/null 2>&1 || true
unset -f explode_ansible_role || true
explode_ansible_role() {
    local input_file="$1"
    local full_role_path="$2" # This is the full path including the role name

    # Validate arguments
    if [ -z "$input_file" ] || [ -z "$full_role_path" ]; then
        echo "Usage: explode_ansible_role <path_to_combined_role_file> <path_to_role_target_location>"
        echo "Example: explode_ansible_role ~/<role_name>.yml roles/<role_name>"
        return 1
    fi

    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' not found."
        return 1
    fi

    # Determine role name from the full_role_path
    local role_name
    role_name=$(basename "$full_role_path")

    # Define paths for the new role's components
    local tasks_dir
    local defaults_dir
    local meta_dir
    local handlers_dir

    tasks_dir="${full_role_path}/tasks"
    defaults_dir="${full_role_path}/defaults"
    meta_dir="${full_role_path}/meta"
    handlers_dir="${full_role_path}/handlers"

    echo "Creating Ansible role '${role_name}' structure at: ${full_role_path}"

    # Create directories
    mkdir -p "$tasks_dir" || {
        echo "Failed to create ${tasks_dir}"
        return 1
    }
    mkdir -p "$defaults_dir" || {
        echo "Failed to create ${defaults_dir}"
        return 1
    }
    mkdir -p "$meta_dir" || {
        echo "Failed to create ${meta_dir}"
        return 1
    }
    mkdir -p "$handlers_dir" || {
        echo "Failed to create ${handlers_dir}"
        return 1
    }

    echo "Extracting content from '$input_file' and writing to role files..."

    local current_output_file=""
    local current_file_descriptor=""

    # Read the input file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check for start markers
        if [[ "$line" =~ ^#\ FILE:\ (.*)$ ]]; then
            # Close previous file if open
            if [ -n "$current_file_descriptor" ]; then
                exec {current_file_descriptor}>&-
                current_file_descriptor=""
            fi

            local relative_path="${BASH_REMATCH[1]}"
            # Determine the full path for the current output file
            case "$relative_path" in
            "prepare_kubernetes/tasks/main.yml")
                current_output_file="${tasks_dir}/main.yml"
                ;;
            "prepare_kubernetes/defaults/main.yml")
                current_output_file="${defaults_dir}/main.yml"
                ;;
            "prepare_kubernetes/meta/main.yml")
                current_output_file="${meta_dir}/main.yml"
                ;;
            "prepare_kubernetes/handlers/main.yml")
                current_output_file="${handlers_dir}/main.yml"
                ;;
            *)
                echo "Warning: Unrecognized file path marker: '$relative_path'. Skipping content."
                current_output_file="" # Reset to ignore content until next recognized marker
                continue
                ;;
            esac
            # Open new file for writing (redirect stdout for subsequent echoes)
            exec {current_file_descriptor}>"$current_output_file"
            echo "  --> Writing to: ${current_output_file}"
            continue # Skip the marker line itself
        fi

        # If we have an open file descriptor, write the line to it
        if [ -n "$current_file_descriptor" ]; then
            echo "$line" >&"$current_file_descriptor"
        fi
    done <"$input_file"

    # Close the last file if it was open
    if [ -n "$current_file_descriptor" ]; then
        exec {current_file_descriptor}>&-
    fi

    echo "Ansible role '${role_name}' created successfully at ${full_role_path}."
}

#
# Function to concatenate all files of a directory into a single text file.
# The output file is named after the specified directory.
#
unalias package_directory 1>/dev/null 2>&1 || true
unset -f package_directory || true
function package_directory() {
    if [ -z "$1" ]; then
        echo "Usage: package_directory <directory_path> [additional_ignore_dir1] [additional_ignore_dir2] ..."
        return 1
    fi

    # --- Configuration ---
    DIR_PATH="${1%/}"

    if [ ! -d "$DIR_PATH" ]; then
        echo "Error: Directory path '$DIR_PATH' does not exist."
        return 1
    fi

    # Base exclude patterns
    BASE_EXCLUDES="\.git|\.idea|\.DS_Store|\.test|\.tmp|__pycache__|output|save|releases|archive|old"

    # Capture all arguments after the first one as custom ignores
    shift
    CUSTOM_EXCLUDES=""
    for arg in "$@"; do
        # Escape any dots or special regex characters in user input just in case
        escaped_arg=$(echo "$arg" | sed 's/\./\\./g')
        if [ -z "$CUSTOM_EXCLUDES" ]; then
            CUSTOM_EXCLUDES="$escaped_arg"
        else
            CUSTOM_EXCLUDES="${CUSTOM_EXCLUDES}|${escaped_arg}"
        fi
    done

    # Combine base and custom excludes into the final regex
    if [ -n "$CUSTOM_EXCLUDES" ]; then
        EXCLUDE_REGEX=".*/(${BASE_EXCLUDES}|${CUSTOM_EXCLUDES})$"
    else
        EXCLUDE_REGEX=".*/(${BASE_EXCLUDES})$"
    fi

    # Resolve absolute path
    ABS_DIR_PATH=$(cd "$DIR_PATH" && pwd)
    DIRECTORY_NAME=$(basename "${ABS_DIR_PATH}")

    # Default output path (since $2 is now used for ignores)
    OUTPUT_FILE="${DIR_PATH}/save/directory.${DIRECTORY_NAME}.txt"
    OUTPUT_DIR=$(dirname "${OUTPUT_FILE}")

    echo "Ensuring output dir exists: ${OUTPUT_DIR}"
    mkdir -p "${OUTPUT_DIR}"
    # shellcheck disable=SC2188
    >"${OUTPUT_FILE}"

    echo "Packaging directory: ${DIRECTORY_NAME}"
    echo "Excluding patterns matching: ${EXCLUDE_REGEX}"
    echo "Filtering out non-text files..."
    echo "---"

    # Use the EXCLUDE_REGEX variable in the find command
    # -L: Follow symlinks
    # -regextype posix-extended: Ensures the variable is interpreted correctly
    find -L "$DIR_PATH" \
        -regextype posix-extended -regex "$EXCLUDE_REGEX" -prune \
        -o \( -type f -o -type l \) -print | while read -r FILE_PATH; do

        # Prevent the script from reading its own output file
        [[ "${FILE_PATH}" == "${OUTPUT_FILE}" ]] && continue

        # Check for binary content (dereferencing symlinks with -L)
        IS_BINARY=$(file -L -b --mime "$FILE_PATH" | grep "charset=binary")

        if [ -z "$IS_BINARY" ] && [ -f "$FILE_PATH" ]; then
            RELATIVE_PATH="${FILE_PATH#$DIR_PATH/}"

            # SC2129: Grouping redirects for efficiency and readability
            {
                echo "### FILE: $RELATIVE_PATH ###"
                echo ""
                cat "$FILE_PATH"
                echo ""
                echo "### END FILE: $RELATIVE_PATH ###"
                echo ""
            } >>"$OUTPUT_FILE"
        elif [ -n "$IS_BINARY" ]; then
            echo "Skipping binary: $FILE_PATH" >&2
        fi
    done

    echo "---"
    echo "Packaging complete! Saved in '$OUTPUT_FILE'."
}

#
# Function to concatenate all files of a Java directory into a single text file.
# Inherits behavior from package_directory while automatically excluding "resources".
#
unalias package_java_directory 1>/dev/null 2>&1 || true
unset -f package_java_directory || true
function package_java_directory() {
    if [ -z "$1" ]; then
        echo "Usage: package_java_directory <directory_path> [additional_ignore_dir1] [additional_ignore_dir2] ..."
        return 1
    fi

    # Pass all incoming arguments to package_directory, automatically excluding "resources/" "gradle/" "build/"
    package-dir.sh "$1" "resources" "gradle" "build" "${@:2}"
}

#
# Function to concatenate all files of a directory into a single text file.
# The output file is named after the specified directory.
#
unalias package_git_directory 1>/dev/null 2>&1 || true
unset -f package_git_directory || true
function package_git_directory() {
    if [ -z "$1" ]; then
        echo "Usage: package_git_directory <directory_path>"
        return 1
    fi

    # 1. Normalize and Resolve Paths
    DIR_PATH="${1%/}"
    if [ ! -d "$DIR_PATH" ]; then
        echo "Error: Directory path '$DIR_PATH' does not exist."
        return 1
    fi

    ABS_DIR_PATH=$(cd "$DIR_PATH" && pwd)
    DIRECTORY_NAME=$(basename "${ABS_DIR_PATH}")
    OUTPUT_FILE_DEFAULT="${DIR_PATH}/save/directory.${DIRECTORY_NAME}.txt"
    OUTPUT_FILE="${2:-${OUTPUT_FILE_DEFAULT}}"
    OUTPUT_DIR=$(dirname "${OUTPUT_FILE}")

    mkdir -p "${OUTPUT_DIR}"
    # shellcheck disable=SC2188
    >"${OUTPUT_FILE}"

    echo "Packaging directory: ${DIRECTORY_NAME}"
    echo "Output: ${OUTPUT_FILE}"

    # 2. Use 'git -C' to execute within the target directory context
    # This ensures paths returned are relative to DIR_PATH, not the Git root
    git -C "$DIR_PATH" ls-files --cached --others --exclude-standard | while read -r RELATIVE_PATH; do

        # In this context, FILE_PATH is correctly constructed
        FILE_PATH="${DIR_PATH}/${RELATIVE_PATH}"

        # 3. Enhanced Text-Check
        # We check for "binary" BUT we specifically allow common text/config types
        # that sometimes trip up the 'file' command's binary detection.
        MIME_INFO=$(file -b --mime "$FILE_PATH")

        IS_TEXT=false
        if [[ "$MIME_INFO" != *"charset=binary"* ]]; then
            IS_TEXT=true
            #        # Fallback: Force include specific text-based extensions even if 'file' is unsure
            #        elif [[ "$FILE_PATH" =~ \.(yml|yaml|md|txt|cfg|conf|sh|py|ini|json|gitignore)$ ]]; then
            #            IS_TEXT=true
        fi

        if [ "$IS_TEXT" = true ]; then
            {
                echo "### FILE: $RELATIVE_PATH ###"
                echo ""
                cat "$FILE_PATH"
                echo ""
                echo "### END FILE: $RELATIVE_PATH ###"
                echo ""
            } >>"$OUTPUT_FILE"
        else
            echo "Skipping binary: $RELATIVE_PATH" >&2
        fi
    done

    echo "Packaging complete!"
}

unalias mypy_lint 1>/dev/null 2>&1 || true
unset -f mypy_lint || true
function mypy_lint() {
    # Check if a path is provided
    if [ -z "$1" ]; then
        echo "Usage: mypy_lint <path>"
        echo "Example: mypy_lint tests/test_agent_pipeline.py"
        return 1
    fi

    LINT_TARGET_PATH="$1"

    # Check if the path exists as EITHER a file OR a directory
    if [ ! -d "$LINT_TARGET_PATH" ] && [ ! -f "$LINT_TARGET_PATH" ]; then
        echo "Error: Path '$LINT_TARGET_PATH' does not exist."
        return 1
    fi

    echo "=============================="
    echo "Running Mypy..."
    echo "=============================="
    echo "mypy --strict ${LINT_TARGET_PATH}"
    mypy --strict "${LINT_TARGET_PATH}"

    echo ""
    echo "=============================="
    echo "Running Flake8..."
    echo "=============================="
    echo "flake8 ${LINT_TARGET_PATH}"
    flake8 "${LINT_TARGET_PATH}"

    echo ""
    echo "=============================="
    echo "Running Pylint..."
    echo "=============================="

    # Try to find the Git repository root safely
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

    # Check if we are inside a Git repo and if a .pylintrc exists at its root
    if [ -n "$REPO_ROOT" ] && [ -f "$REPO_ROOT/.pylintrc" ]; then
        echo "pylint --rcfile=$REPO_ROOT/.pylintrc ${LINT_TARGET_PATH}"
        pylint --rcfile="$REPO_ROOT/.pylintrc" "${LINT_TARGET_PATH}"
    else
        # Fallback: Run pylint without forcing a specific root rcfile
        echo "pylint ${LINT_TARGET_PATH}"
        pylint "${LINT_TARGET_PATH}"
    fi
}

unalias git_rebase_upstream 1>/dev/null 2>&1 || true
unset -f git_rebase_upstream || true
function git_rebase_upstream() {
    local current_branch
    current_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
    if [ -z "$current_branch" ]; then
        echo "Error: Detached HEAD state. Please checkout a branch first." 1>&2
        return 1
    fi

    local target_remote="${1:-upstream}"
    local target_branch="${2:-main}"
    local upstream_ref="${target_remote}/${target_branch}"

    echo "Current branch: $current_branch"
    echo "Target upstream: $upstream_ref"

    echo "Fetching latest changes from $target_remote..."
    git fetch "$target_remote" || return 1

    echo "Rebasing $current_branch onto $upstream_ref..."
    git rebase "$upstream_ref" || return 1

    # Determine tracking push destination (defaults to 'github' or 'origin')
    local push_remote="github"
    if ! git remote | grep -q "^github$"; then
        push_remote="origin"
    fi

    # Map local 'public' branch to remote 'main', otherwise match branch names
    local remote_branch="$current_branch"
    if [ "$current_branch" = "public" ]; then
        remote_branch="main"
    fi

    echo "Rebase complete. Pushing to $push_remote/$remote_branch (force-with-lease)..."
    git push --force-with-lease "$push_remote" "$current_branch:$remote_branch"
}

# Compare current branch to another and save to a file
unalias git_branch_diffs 1>/dev/null 2>&1 || true
unset -f git_branch_diffs || true
function git_branch_diffs() {
    # 1. Configuration & Variables
    local target_branch="$1"
    local out_dir="${2:-save/}"

    # Validation: Ensure a branch was provided
    if [ -z "$target_branch" ]; then
        echo "Usage: git-branch-diffs <compare-branch> [output-directory]"
        return 1
    fi

    # Validation: Ensure branch exists
    if ! git rev-parse --verify "$target_branch" >/dev/null 2>&1; then
        echo "Error: Branch '$target_branch' does not exist."
        return 1
    fi

    # 2. Dynamic Naming
    # Format: YYYYMMDD_HHMMSS (e.g., 20260201_143015)
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    # Clean the branch name (replace slashes with dashes for filename safety)
    local safe_branch_name
    local file_name
    local full_path
    safe_branch_name=$(echo "$target_branch" | sed 's/\//-/g')
    file_name="git-branch-diffs.${safe_branch_name}.${timestamp}.txt"
    full_path="${out_dir%/}/$file_name"

    # 3. Execution
    mkdir -p "$out_dir"
    echo "Comparing current branch to: $target_branch"

    # Generate the diff (Unified format, respects .gitignore)
    # Using 'target..HEAD' shows what has changed in YOUR branch relative to target
    git diff "$target_branch"..HEAD >"$full_path"

    # 4. Results & Summary
    if [ -s "$full_path" ]; then
        echo "Success! Difference file created at: $full_path"
        echo "--- Summary ---"
        git diff "$target_branch"..HEAD --stat
    else
        echo "No differences found between current branch and $target_branch."
        # Clean up empty file if no diff exists
        [ -f "$full_path" ] && rm "$full_path"
    fi
}


## ref: https://gist.github.com/stephenhardy/5470814?permalink_comment_id=3671126#gistcomment-3671126
unalias git_reset_branch_history 1>/dev/null 2>&1 || true
unset -f git_reset_branch_history || true
function git_reset_branch_history() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE_NAME REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git checkout --orphan newBranch &&
        echo "==> Add all files and commit them" &&
        (git add -A || true) &&
        git commit -am "Initial commit" &&
        echo "==> Delete the ${LOCAL_BRANCH} branch" &&
        git branch -D "${LOCAL_BRANCH}" &&
        echo "==> Rename the current branch to ${LOCAL_BRANCH}" &&
        git branch -m "${LOCAL_BRANCH}" &&
        echo "==> Force push ${REMOTE_BRANCH} branch to ${REMOTE_NAME}" &&
        git push -f "${REMOTE_NAME}" "${REMOTE_BRANCH}" &&
        echo "==> remove the old files" &&
        git gc --aggressive --prune=all
}

## make these function so they evaluate at time of exec and not upon shell startup
## Prevent bash alias from evaluating statement at shell start
## ref: https://stackoverflow.com/questions/13260969/prevent-bash-alias-from-evaluating-statement-at-shell-start
#alias gitpush.="git push origin $(git rev-parse --abbrev-ref HEAD)"
#alias gitsetupstream="git branch --set-upstream-to=origin/$(git symbolic-ref HEAD 2>/dev/null)"

unalias git_reset_public_branch 1>/dev/null 2>&1 || true
unset -f git_reset_public_branch || true
function git_reset_public_branch() {
    GIT_DEFAULT_BRANCH=main

    ## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
    # exit when any command fails
    set -e

    # keep track of the last executed command
    trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
    # echo an error message before exiting
    trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

    echo "Check out ${GIT_DEFAULT_BRANCH} branch:"
    git checkout ${GIT_DEFAULT_BRANCH}

    #echo "Delete current local public branch:"
    #git branch -D public

    echo "Check out to a temporary branch:"
    git checkout --orphan TEMP_BRANCH

    echo "Update public files:"
    if [ -d docs ]; then
        rm -fr docs/
    fi
    if [ -d private ]; then
        rm -fr private/
    fi
    if [ -d files/private ]; then
        rm -fr files/private/
    fi
    find . -name secrets.yml -exec rm -rf {} \;
    find . -name vault.yml -exec rm -rf {} \;

    echo "Add all the files:"
    git add -A

    echo "Commit the changes:"
    git commit -am "Initial commit"

    echo "Delete the old branch:"
    git branch -D public

    echo "Rename the temporary branch to public:"
    ## ref: https://gist.github.com/heiswayi/350e2afda8cece810c0f6116dadbe651
    git branch -m public

    echo "Force public branch update to origin repository:"
    git push -f origin public
    #git push -f --set-upstream origin public

    echo "Force public branch update to github repository:"
    git push -f -u github public:main

    echo "Finally, checkout ${GIT_DEFAULT_BRANCH} branch:"
    git checkout ${GIT_DEFAULT_BRANCH}
}

unalias git_show_upstream 1>/dev/null 2>&1 || true
unset -f git_show_upstream || true
function git_show_upstream() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        echo ${REMOTE_AND_BRANCH}
}

unalias git_set_upstream 1>/dev/null 2>&1 || true
unset -f git_set_upstream || true
git_set_upstream() {
    REMOTE_NAME=${1:-"origin"}
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)"
    REMOTE_BRANCH=${2:-"${LOCAL_BRANCH}"}
    echo LOCAL_BRANCH=${LOCAL_BRANCH} &&
        echo REMOTE_BRANCH=${REMOTE_BRANCH} &&
        git branch --set-upstream-to=${REMOTE_NAME}/${REMOTE_BRANCH} ${LOCAL_BRANCH}
}

unalias git_pull 1>/dev/null 2>&1 || true
unset -f git_pull || true
function git_pull() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git pull ${REMOTE} ${REMOTE_BRANCH}
}

## resolve issue "Fatal: Not possible to fast-forward, aborting"
## ref: https://stackoverflow.com/questions/13106179/fatal-not-possible-to-fast-forward-aborting
#alias gitpullrebase="git pull origin <branch> --rebase"
unalias git_pull_rebase 1>/dev/null 2>&1 || true
unset -f git_pull_rebase || true
function git_pull_rebase() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git pull ${REMOTE} ${REMOTE_BRANCH} --rebase
}

unalias git_push 1>/dev/null 2>&1 || true
unset -f git_push || true
function git_push() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git push ${REMOTE} ${REMOTE_BRANCH}
}

unalias git_pull_work 1>/dev/null 2>&1 || true
unset -f git_pull_work || true
function git_pull_work() {
    GIT_SSH_COMMAND="ssh -i ~/.ssh/${SSH_KEY_WORK}" git pull bitbucket $(git rev-parse --abbrev-ref HEAD)
}

unalias git_push_work 1>/dev/null 2>&1 || true
unset -f git_push_work || true
function git_push_work() {
    GIT_SSH_COMMAND="ssh -i ~/.ssh/${SSH_KEY_WORK}" git push bitbucket $(git rev-parse --abbrev-ref HEAD)
}

unalias git_pull_github 1>/dev/null 2>&1 || true
unset -f git_pull_github || true
function git_pull_github() {
    GIT_SSH_COMMAND="ssh -i ~/.ssh/${SSH_KEY_GITHUB}" git pull github $(git rev-parse --abbrev-ref HEAD)
}

unalias git_push_github 1>/dev/null 2>&1 || true
unset -f git_push_github || true
function git_push_github() {
    GIT_SSH_COMMAND="ssh -i ~/.ssh/${SSH_KEY_GITHUB}" git push github $(git rev-parse --abbrev-ref HEAD)
}

unalias git_branch_delete 1>/dev/null 2>&1 || true
unset -f git_branch_delete || true
function git_branch_delete() {
    REPO_ORIGIN_URL="$(git config --get remote.origin.url)" &&
        REPO_DEFAULT_BRANCH="$(git ls-remote --symref "${REPO_ORIGIN_URL}" HEAD | sed -nE 's|^ref: refs/heads/(\S+)\s+HEAD|\1|p')" &&
        LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git checkout "${REPO_DEFAULT_BRANCH}" &&
        echo "==> Deleting local branch ${LOCAL_BRANCH}" &&
        git branch -D "${LOCAL_BRANCH}" &&
        echo "==> Deleting remote ${REMOTE} branch ${REMOTE_BRANCH}" &&
        git push -d "${REMOTE}" "${REMOTE_BRANCH}"
}

unalias git_branch_recreate 1>/dev/null 2>&1 || true
unset -f git_branch_recreate || true
function git_branch_recreate() {
    REPO_ORIGIN_URL="$(git config --get remote.origin.url)" &&
        REPO_DEFAULT_BRANCH="$(git ls-remote --symref "${REPO_ORIGIN_URL}" HEAD | sed -nE 's|^ref: refs/heads/(\S+)\s+HEAD|\1|p')" &&
        LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git fetch origin "${REPO_DEFAULT_BRANCH}":"${REPO_DEFAULT_BRANCH}" &&
        echo "==> Deleting existing branch ${LOCAL_BRANCH}" &&
        git_branch_delete &&
        echo "==> Creating new branch ${LOCAL_BRANCH}" &&
        git checkout -b "${LOCAL_BRANCH}" &&
        echo "==> Pushing new branch ${LOCAL_BRANCH}" &&
        git push -u "${REMOTE}" "${LOCAL_BRANCH}"
}

unalias git_branch_hist 1>/dev/null 2>&1 || true
unset -f git_branch_hist || true
function git_branch_hist() {
    ## How to get commit history for just one branch?
    ## ref: https://stackoverflow.com/questions/16974204/how-to-get-commit-history-for-just-one-branch
    git log $(git rev-parse --abbrev-ref HEAD)..
}

unalias git_request_id 1>/dev/null 2>&1 || true
unset -f git_request_id || true
function git_request_id() {
    PROJECT_DIR="$(git rev-parse --show-toplevel)"
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)"
    COMMENT_PREFIX=$(echo "${LOCAL_BRANCH}" | cut -d- -f1-2)

    #  if [[ $COMMENT_PREFIX = *develop* ]]; then
    if [[ $COMMENT_PREFIX = *develop* || $COMMENT_PREFIX = *main* || $COMMENT_PREFIX = *master* ]]; then
        if [ -f ${PROJECT_DIR}/.git.request.refid ]; then
            COMMENT_PREFIX=$(cat ${PROJECT_DIR}/.git.request.refid)
        elif [ -f ${HOME}/.git.request.refid ]; then
            COMMENT_PREFIX=$(cat ${HOME}/.git.request.refid)
        elif [ -f ${PROJECT_DIR}/save/.git.request.refid ]; then
            COMMENT_PREFIX=$(cat ${PROJECT_DIR}/save/.git.request.refid)
        elif [ -f ./.git.request.refid ]; then
            COMMENT_PREFIX=$(cat ./.git.request.refid)
        fi
    fi
    echo "${COMMENT_PREFIX}"
}

## https://stackoverflow.com/questions/35010953/how-to-automatically-generate-commit-message
unalias git_comment 1>/dev/null 2>&1 || true
unset -f git_comment || true
function git_comment() {
    COMMENT_PREFIX=$(git_request_id)
    COMMENT_BODY="$(LANG=C git -c color.status=false status |
        sed -n -E -e '1,/Changes to be committed:/ d' \
            -e '1,1 d' \
            -e '/^Untracked files:/,$ d' \
            -e 's/^\s*//' \
            -e '/./p' |
        sed -e '/git restore/ d')"
    GIT_COMMENT="${COMMENT_PREFIX} - ${COMMENT_BODY}"
    echo "${GIT_COMMENT}"
}

unalias git_commit_push 1>/dev/null 2>&1 || true
unset -f git_commit_push || true
function git_commit_push() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        GIT_COMMENT=$(git_comment) &&
        echo "Committing changes:" &&
        git commit -am "${GIT_COMMENT}" || true &&
        echo "Pushing local branch ${LOCAL_BRANCH} to remote ${REMOTE} branch ${REMOTE_BRANCH}:" &&
        git push ${REMOTE} ${LOCAL_BRANCH}:${REMOTE_BRANCH}
}

unalias git_add_commit_push 1>/dev/null 2>&1 || true
unset -f git_add_commit_push || true
function git_add_commit_push() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE_NAME REMOTE_BRANCH <<<"${REMOTE_AND_BRANCH}" &&
        echo "Staging changes:" &&
        git add . || true &&
        GIT_COMMENT=$(git_comment) &&
        echo "Committing changes:" &&
        git commit -am "${GIT_COMMENT}" || true &&
        echo "Pushing local branch ${LOCAL_BRANCH} to remote ${REMOTE_NAME} branch ${REMOTE_BRANCH}:" &&
        git push -f -u "${REMOTE_NAME}" "${LOCAL_BRANCH}:${REMOTE_BRANCH}"
}

unalias git_pacp 1>/dev/null 2>&1 || true
unset -f git_pacp || true
function git_pacp() {
    ## https://stackoverflow.com/questions/5738797/how-can-i-push-a-local-git-branch-to-a-remote-with-a-different-name-easily
    ## https://stackoverflow.com/questions/46514831/how-read-the-current-upstream-for-a-git-branch
    # LANG=C.UTF-8 or any UTF-8 English locale supported by your OS may be used
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git pull ${REMOTE} ${REMOTE_BRANCH} &&
        git_add_commit_push
}

unalias git_remove_cached 1>/dev/null 2>&1 || true
unset -f git_remove_cached || true
function git_remove_cached() {
    LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        git rm -r --cached . &&
        git_add_commit_push
}

## https://stackoverflow.com/questions/38892599/change-commit-message-for-specific-commit
unalias git_change_commit_msg 1>/dev/null 2>&1 || true
unset -f git_change_commit_msg || true
function git_change_commit_msg() {

    COMMIT_ID="$1"
    NEW_MSG="$2"
    BRANCH=${3-$(git rev-parse --abbrev-ref HEAD)}

    git checkout $COMMIT_ID &&
        echo "commit new msg $NEW_MSG" &&
        git commit --amend -m "$NEW_MSG" &&
        echo "git cherry-pick $COMMIT_ID..$BRANCH" &&
        git cherry-pick $COMMIT_ID..$BRANCH &&
        echo "git branch -f $BRANCH" &&
        git branch -f $BRANCH &&
        echo "git checkout $BRANCH" &&
        git checkout $BRANCH

}

## https://stackoverflow.com/questions/24609146/stop-git-merge-from-opening-text-editor
#git config --global alias.merge-no-edit '!env GIT_EDITOR=: git merge'
unalias git_merge_branch 1>/dev/null 2>&1 || true
unset -f git_merge_branch || true
function git_merge_branch() {

    MERGE_BRANCH="${1-public}" &&
        LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        echo "Fetch all" &&
        git fetch --all &&
        echo "Checkout ${MERGE_BRANCH}" &&
        git checkout ${MERGE_BRANCH} &&
        REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${MERGE_BRANCH}@{upstream}) &&
        IFS=/ read REMOTE REMOTE_BRANCH <<<${REMOTE_AND_BRANCH} &&
        echo "Pull ${REMOTE} ${REMOTE_BRANCH}" &&
        git pull ${REMOTE} ${REMOTE_BRANCH} &&
        echo "Checkout ${LOCAL_BRANCH}" &&
        git checkout ${LOCAL_BRANCH} &&
        echo "Merge ${MERGE_BRANCH}" &&
        git merge-no-edit -X theirs ${MERGE_BRANCH}
}

unalias git_clone_work 1>/dev/null 2>&1 || true
unset -f git_clone_work || true
function git_clone_work() {
    GIT_REPO="${1}" &&
        REPO_DIR=$(basename ${GIT_REPO%.*}) &&
        GIT_SSH_COMMAND="ssh -i ~/.ssh/${SSH_KEY_WORK}" git clone ${GIT_REPO} &&
        pushd . &&
        cd $REPO_DIR &&
        git config core.sshCommand "ssh -i ~/.ssh/${SSH_KEY_WORK}" &&
        popd
}

unalias git_update_sub 1>/dev/null 2>&1 || true
unset -f git_update_sub || true
function git_update_sub() {
    git submodule deinit -f . &&
        git submodule update --init --recursive --remote
}

unalias git_reinit_repo 1>/dev/null 2>&1 || true
unset -f git_reinit_repo || true
function git_reinit_repo() {
    SAVE_DATE=$(date +%Y%m%d_%H%M) &&
        GIT_ORIGIN_REPO=$(git config --get remote.origin.url) &&
        LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" &&
        GIT_REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) &&
        IFS=/ read GIT_REMOTE_REPO GIT_REMOTE_BRANCH <<<${GIT_REMOTE_AND_BRANCH} &&
        echo "reinitialize git repo and push to remote origin ${GIT_ORIGIN_REPO} [${GIT_REMOTE_REPO}] with branch ${GIT_REMOTE_BRANCH}" &&
        mkdir -p save &&
        mv .git save/.git.${SAVE_DATE} &&
        git init &&
        git remote add origin ${GIT_ORIGIN_REPO} &&
        git add . &&
        git commit -m "Initial commit" &&
        git push -u --force origin ${GIT_REMOTE_BRANCH}
}


unalias ssh_reset_keys 1>/dev/null 2>&1 || true
unset -f ssh_reset_keys || true
function ssh_reset_keys() {
    local TARGET_HOST="$1"
    ssh-keygen -R "${TARGET_HOST}" && ssh-keyscan -H "${TARGET_HOST}"
}

##
##
unalias install_dev_env 1>/dev/null 2>&1 || true
unset -f install_dev_env || true
function install_dev_env() {
    echo "DEVENV_INSTALL_REMOTE_SCRIPT=${DEVENV_INSTALL_REMOTE_SCRIPT}"
    curl -fsSL "${DEVENV_INSTALL_REMOTE_SCRIPT}" | bash -s -- "$@"
    #  bash -c "$(curl -fsSL "${DEVENV_INSTALL_REMOTE_SCRIPT}")"
}

## ref: https://gist.github.com/vby/ef4d72e6ae51c64acbe7790ca7d89606#file-msys2-bashrc-sh
unalias add_winpath 1>/dev/null 2>&1 || true
unset -f add_winpath || true
function add_winpath() {
    paths=''
    __IFS=$IFS
    IFS=';'
    for path in $(cat $1/Path); do
        paths="$paths:$(cygpath -u $path)"
    done
    IFS=$__IFS
    export PATH="$PATH:$paths"
}

#####
## gpu / llm
unalias check_nvidia_version 1>/dev/null 2>&1 || true
unset -f check_nvidia_version || true
check_nvidia_version() {
    local proc_ver mod_ver

    # Extract driver version from /proc/driver/nvidia/version
    proc_ver=$(grep -oP 'NVRM version:.*?\b\K[0-9]+\.[0-9]+(\.[0-9]+)?' /proc/driver/nvidia/version 2>/dev/null)

    # Extract version field from modinfo nvidia
    mod_ver=$(modinfo nvidia 2>/dev/null | awk '/^version:/ {print $2}')

    # Handle missing files/modules
    if [[ -z "$proc_ver" || -z "$mod_ver" ]]; then
        echo "❌ Error: Could not read NVIDIA version from one or both sources."
        return 1
    fi

    echo "Proc driver version: $proc_ver"
    echo "Modinfo version:     $mod_ver"

    # Match if mod_ver starts with proc_ver (or vice-versa)
    if [[ "$mod_ver" == "$proc_ver"* || "$proc_ver" == "$mod_ver"* ]]; then
        echo "✅ Versions match."
        return 0
    else
        echo "⚠️ Mismatch detected! (Proc: $proc_ver vs Modinfo: $mod_ver)"
        return 2
    fi
}

##
##
unalias setenv_python 1>/dev/null 2>&1 || true
unset -f setenv_python || true
function setenv_python() {
    python_version=${1:-"3WIN"}
    add2path=${2:-0}

    local logPrefix="setenv_python"
    #	echo "python_version=[${python_version}]"

    case "${python_version}" in
    3WIN)
        PYTHON_HOME=$PYTHON3_HOME_WIN
        PYTHON_BIN_DIR=$PYTHON3_BIN_DIR_WIN
        PYTHONDIR=$PYTHON3_BIN_DIR_WIN
        VENV_BINDIR="Scripts"
        PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
        export PATH=$PYTHON_HOME/scripts:$PATH
        export PATH=$PYTHON_SCRIPTDIR:$PATH
        export PATH=$PYTHON_BIN_DIR:$PATH
        ;;
    3)
        PYTHON_HOME=$PYTHON3_HOME
        PYTHON_BIN_DIR=$PYTHON3_BIN_DIR
        PYTHONDIR=$PYTHON3_BIN_DIR
        VENV_BINDIR="bin"
        PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
        ;;
    2WIN)
        PYTHON_HOME=$PYTHON2_HOME_WIN
        PYTHON_BIN_DIR=$PYTHON2_BIN_DIR_WIN
        PYTHONDIR=$PYTHON2_BIN_DIR_WIN
        PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
        export PATH=$PYTHON_HOME/scripts:$PATH
        export PATH=$PYTHON_SCRIPTDIR:$PATH
        export PATH=$PYTHON_BIN_DIR:$PATH
        VENV_BINDIR="Scripts"
        ;;
    2)
        PYTHON_HOME=$PYTHON2_HOME
        PYTHON_BIN_DIR=$PYTHON2_BIN_DIR
        PYTHONDIR=$PYTHON2_BIN_DIR
        VENV_BINDIR="bin"
        PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
        ;;
    *)
        platform="UNKNOWN:python_version=${python_version}"
        ;;
    esac

    #	echo "PYTHON_HOME=[${PYTHON_HOME}]"

    #	echo "PATH=$PATH"

    export PYTHON=$PYTHON_BIN_DIR/python
    alias .venv=". ./venv/${VENV_BINDIR}/activate"

}

unalias get_certs 1>/dev/null 2>&1 || true
unset -f get_certs || true
function get_certs() {

    DATE=$(date +%Y%m%d%H%M%S)

    echo "**********************************"
    echo "*** installing certs"
    echo "**********************************"

    #CERT_DEST_DIR="${HOME}/.ssh"
    #CERT_DEST_DIR="/home/administrator/.ssh"
    CERT_DEST_DIR="${HOME}/.ssh"

    #INITIAL_WD=`pwd`
    #    SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
    #    echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

    #    CERT_SRC_DIR="${SCRIPT_DIR}/../certs/.ssh"
    #    CERT_SRC_DIR="/opt/pyutils/certs/.ssh"
    CERT_SRC_DIR="${PYUTILS_DIR}/certs/.ssh"

    echo "CERT_SRC_DIR=[${CERT_SRC_DIR}]"
    echo "CERT_DEST_DIR=[${CERT_DEST_DIR}]"

    FROM="${CERT_SRC_DIR}/"
    TO="${CERT_DEST_DIR}/"
    BACKUP="${CERT_DEST_DIR}/backups"
    #BACKUP="backups"

    if [ ! -d $CERT_SRC_DIR ]; then
        echo "CERT_SRC_DIR not found at ${CERT_SRC_DIR}, exiting..."
        exit 1
    fi

    ## rsync can backup and sync
    ## ref: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

    # OPTIONS=(
    #     -arv
    #     --update
    #     --backup
    #     --backup-dir=$BACKUP
    # )

    OPTIONS=(
        -arv
        --update
    )

    #echo "rsync ${OPTIONS[@]} $FROM $TO"
    echo "rsync ${OPTIONS[@]} $FROM $TO"

    rsync ${OPTIONS[@]} ${FROM} ${TO}

    chmod 600 ${CERT_DEST_DIR}/id_rsa

}

## ref: https://stackoverflow.com/questions/42635253/display-received-cert-with-curl
## example usage:
##
##   get_host_cert_info admin2.johnson.int 5000
##
unalias get_host_cert_info 1>/dev/null 2>&1 || true
unset -f get_host_cert_info || true
function get_host_cert_info() {
    local host="$1"
    local port="${2:-443}"

    if [ -z "$host" ]; then
        echo "Usage: get_host_cert_info <host> [port]" >&2
        return 1
    fi

    echo "=== DNS Lookup for $host ==="
    nslookup "$host"
    echo ""

    # Construct the exact command string for logging and execution
    local cmd="openssl s_client -showcerts -servername ${host} -connect ${host}:${port} </dev/null 2>/dev/null | openssl x509 -text"

    echo "=== Executing Command ==="
    echo "  $cmd"
    echo "========================="
    echo ""

    eval "$cmd"
}

unalias get_cert_fingerprint 1>/dev/null 2>&1 || true
unset -f get_cert_fingerprint || true
function get_cert_fingerprint() {
    CERT_PATH=$1
    FINGERPRINT=$(openssl x509 -noout -fingerprint -sha256 -in "${CERT_PATH}")
    FINGERPRINT_TRIMMED=$(echo "${FINGERPRINT}" |
        tr '[:upper:]' '[:lower:]' | tr -d ':' | sed 's/sha256 fingerprint=//')
    echo "SHA-256         => ${FINGERPRINT}"
    echo "SHA-256 trimmed => ${FINGERPRINT_TRIMMED}"
}

unalias reset_local_dns 1>/dev/null 2>&1 || true
unset -f reset_local_dns || true
function reset_local_dns() {
    local LOG_PREFIX="reset_local_dns():"

    if [[ "${PLATFORM}" == *"DARWIN"* ]]; then
        local RESET_DNS_CACHE="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

        echo "${LOG_PREFIX} ${RESET_DNS_CACHE}"
        eval "${RESET_DNS_CACHE}"

        #    echo "${LOG_PREFIX} Restart eaacloop"
        #
        #    ## ref: https://serverfault.com/questions/194832/how-to-start-stop-restart-launchd-services-from-the-command-line#194886
        #    local RESTART_EAACLOOP="sudo launchctl kickstart -k system/net.eaacloop.wapptunneld"
        #
        #    echo "${LOG_PREFIX} ${RESTART_EAACLOOP}"
        #    eval "${RESTART_EAACLOOP}"
    else
        echo "${LOG_PREFIX} function not implemented/defined for current system platform ${PLATFORM} ...yet"
    fi
}

unalias create_git_project 1>/dev/null 2>&1 || true
unset -f create_git_project || true
function create_git_project() {
    local project="$1"

    cd /var/lib/git
    mkdir $project.git
    cd $project.git
    git init --bare
    cd ..
    chown -R git.git $project.git
}

unalias meteor_list_depends 1>/dev/null 2>&1 || true
unset -f meteor_list_depends || true
function meteor_list_depends() {

    for p in $(meteor list | grep '^[a-z]' | awk '{ print $1"@"$2 }'); do
        echo "$p"
        meteor show "$p" | grep -E "^  [a-z]"
        echo
    done
}

unalias find_up 1>/dev/null 2>&1 || true
unset -f find_up || true
function find_up() {
    path=$(pwd)
    while [[ "$path" != "" && ! -e "$path/$1" ]]; do
        path=${path%/*}
    done
    echo "$path"
}

unalias search_repo_keywords 1>/dev/null 2>&1 || true
unset -f search_repo_keywords || true
function search_repo_keywords() {
    local LOG_PREFIX="searchrepokeywords():"

    local REPO_EXCLUDE_DIR_LIST=(".git")
    REPO_EXCLUDE_DIR_LIST+=(".idea")
    REPO_EXCLUDE_DIR_LIST+=("venv")
    REPO_EXCLUDE_DIR_LIST+=("private")
    REPO_EXCLUDE_DIR_LIST+=("save")

    #export -p | sed 's/declare -x //' | sed 's/export //'
    if [ -z ${REPO_EXCLUDE_KEYWORDS+x} ]; then
        echo "${LOG_PREFIX} REPO_EXCLUDE_KEYWORDS not set/defined"
        exit 1
    fi

    echo "${LOG_PREFIX} REPO_EXCLUDE_KEYWORDS=${REPO_EXCLUDE_KEYWORDS}"

    IFS=',' read -ra REPO_EXCLUDE_KEYWORDS_ARRAY <<<"$REPO_EXCLUDE_KEYWORDS"

    echo "${LOG_PREFIX} REPO_EXCLUDE_KEYWORDS_ARRAY=${REPO_EXCLUDE_KEYWORDS_ARRAY[*]}"

    # ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
    #'-e' ==> '\055e'
    local GREP_DELIM=' \055e '
    printf -v GREP_PATTERN_SEARCH "${GREP_DELIM}%s" "${REPO_EXCLUDE_KEYWORDS_ARRAY[@]}"

    ## strip prefix
    local GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH#"$GREP_DELIM"}
    ## strip suffix
    #GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH%"$GREP_DELIM"}

    echo "${LOG_PREFIX} GREP_PATTERN_SEARCH=${GREP_PATTERN_SEARCH}"

    local GREP_COMMAND="grep ${GREP_PATTERN_SEARCH}"
    echo "${LOG_PREFIX} GREP_COMMAND=${GREP_COMMAND}"

    local FIND_DELIM=' -o '
    #  printf -v FIND_EXCLUDE_DIRS "\055path '*/%s/*' -prune${FIND_DELIM}" "${REPO_EXCLUDE_DIR_LIST[@]}"
    printf -v FIND_EXCLUDE_DIRS "! -path '*/%s/*'${FIND_DELIM}" "${REPO_EXCLUDE_DIR_LIST[@]}"
    local FIND_EXCLUDE_DIRS=${FIND_EXCLUDE_DIRS%$FIND_DELIM}

    echo "${LOG_PREFIX} FIND_EXCLUDE_DIRS=${FIND_EXCLUDE_DIRS}"

    ## this works:
    ## find . \( -path '*/.git/*' \) -prune -name '.*' -o -exec grep -i example {} 2>/dev/null +
    ## find . \( -path '*/save/*' -prune -o -path '*/.git/*' -prune \) -o -exec grep -i client1 {} 2>/dev/null +
    ## find . \( ! -path '*/save/*' -o ! -path '*/.git/*' \) -o -exec grep -i client1 {} 2>/dev/null +
    ## ref: https://stackoverflow.com/questions/6565471/how-can-i-exclude-directories-from-grep-r#8692318
    ## ref: https://unix.stackexchange.com/questions/342008/find-and-echo-file-names-only-with-pattern-found
    ## ref: https://www.baeldung.com/linux/find-exclude-paths
    local FIND_CMD="find . \( ${FIND_EXCLUDE_DIRS} \) -o -exec ${GREP_COMMAND} {} 2>/dev/null +"
    echo "${LOG_PREFIX} ${FIND_CMD}"

    local EXCEPTION_COUNT=$(eval "${FIND_CMD} | wc -l")
    if [[ $EXCEPTION_COUNT -eq 0 ]]; then
        echo "${LOG_PREFIX} SUCCESS => No exclusion keyword matches found!!"
    else
        echo "${LOG_PREFIX} There are [${EXCEPTION_COUNT}] exclusion keyword matches found:"
        eval "${FIND_CMD}"
    fi
    return "${EXCEPTION_COUNT}"
}

unalias cd_nvm 1>/dev/null 2>&1 || true
unset -f cd_nvm || true
function cd_nvm() {
    cd "$@"
    nvm_path=$(find_up .nvmrc | tr -d '[:space:]')

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *"[^[:space:]]"* ]]; then

        declare default_version
        default_version=$(nvm version default)

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [[ $default_version == "N/A" ]]; then
            nvm alias default node
            default_version=$(nvm version default)
        fi

        # If the current version is not the default version, set it to use the default version
        if [[ $(nvm current) != "$default_version" ]]; then
            nvm use default
        fi

    elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
        declare nvm_version
        nvm_version=$(<"$nvm_path"/.nvmrc)

        # Add the `v` suffix if it does not exists in the .nvmrc file
        if [[ $nvm_version != v* ]]; then
            nvm_version="v$nvm_version"
        fi

        # If it is not already installed, install it
        if [[ $(nvm ls "$nvm_version" | tr -d '[:space:]') == "N/A" ]]; then
            nvm install "$nvm_version"
        fi

        if [[ $(nvm current) != "$nvm_version" ]]; then
            nvm use "$nvm_version"
        fi
    fi
}

unalias swarm_status 1>/dev/null 2>&1 || true
unset -f swarm_status || true
function swarm_status() {
    echo "STARTED  = $(docker service ls | grep -c '1/1')" && echo "STARTING = $(docker service ls | grep -c '0/1')"
}

unalias swarm_restart_service 1>/dev/null 2>&1 || true
unset -f swarm_restart_service || true
function swarm_restart_service() {
    SERVICE_ID=${1:-docker_stack_keycloak} &&
        echo "STOPPING SERVICE-ID ${SERVICE_ID}" &&
        docker service scale "${SERVICE_ID}"=0 >/dev/null &&
        echo "STARTING SERVICE-ID ${SERVICE_ID}" &&
        docker service scale "${SERVICE_ID}"=1 >/dev/null &&
        echo "STARTED SERVICE-ID ${SERVICE_ID}"
}

unalias exec_in_container 1>/dev/null 2>&1 || true
unset -f exec_in_container || true
exec_in_container() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: exec_in_container <service_name> <command>" >&2
        return 1
    fi

    local service_name="$1"
    shift

    local container_id=""

    # 1. Try finding container in Docker Swarm mode
    container_id=$(docker ps --filter "label=com.docker.swarm.service.name=${service_name}" -q | head -n 1)

    # 2. If not found, try Docker Compose standalone mode
    if [ -z "$container_id" ]; then
        container_id=$(docker ps --filter "label=com.docker.compose.service=${service_name}" -q | head -n 1)
    fi

    # 3. Fallback: try matching container name directly
    if [ -z "$container_id" ]; then
        container_id=$(docker ps --filter "name=${service_name}" -q | head -n 1)
    fi

    if [ -z "$container_id" ]; then
        echo "Error: No running container found for service '${service_name}'." >&2
        return 1
    fi
    echo "container id ${container_id} found for service '${service_name}'."

    # Execute the command interactively inside the container
    DOCKER_CMD="docker exec -it ${container_id} ${*}"
    echo "${DOCKER_CMD}"
    eval "${DOCKER_CMD}"
}

unalias docker_exec_sh 1>/dev/null 2>&1 || true
unset -f docker_exec_sh || true
function docker_exec_sh() {
    DOCKER_SERVICE_NAME=$1
    exec_in_container "${DOCKER_SERVICE_NAME}" sh
}

unalias docker_exec_bash 1>/dev/null 2>&1 || true
unset -f docker_exec_bash || true
function docker_exec_bash() {
    DOCKER_SERVICE_NAME=$1
    exec_in_container "${DOCKER_SERVICE_NAME}" bash
}

unalias docker_bash 1>/dev/null 2>&1 || true
unset -f docker_bash || true
function docker_bash() {
    CONTAINER_IMAGE_ID="${1}"
    #docker run -p 8443:8443 -v `pwd`/stepca/home:/home/step -it --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
    docker run -it --entrypoint /bin/bash "${CONTAINER_IMAGE_ID}"
}

unalias docker_login 1>/dev/null 2>&1 || true
unset -f docker_login || true
function docker_login() {
    local DOCKER_USERNAME="${1:-"${DOCKER_REGISTRY_USERNAME}"}"
    local DOCKER_PASSWORD="${2:-"${DOCKER_REGISTRY_PASSWORD}"}"
    local DOCKER_REGISTRY="${3:-"${DOCKER_REGISTRY_INTERNAL}"}"
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY}"
}

#unalias docker_exec_sh 1>/dev/null 2>&1 || true
#unset -f docker_exec_sh || true
#function docker_exec_sh() {
#  CONTAINER_IMAGE_ID="${1}"
#  docker exec -it "${CONTAINER_IMAGE_ID}" sh
#}
#
#unalias docker_exec_bash 1>/dev/null 2>&1 || true
#unset -f docker_exec_bash || true
#function docker_exec_bash() {
#  CONTAINER_IMAGE_ID="${1}"
#  docker exec -it "${CONTAINER_IMAGE_ID}" bash
#}

## ref: https://stackoverflow.com/questions/26423515/how-to-automatically-update-your-docker-containers-if-base-images-are-updated
##
unalias docker_sync_image 1>/dev/null 2>&1 || true
unset -f docker_sync_image || true
function docker_sync_image() {
    BASE_IMAGE=${1:-registry}
    REGISTRY=${2:-media.johnson.int:5000}
    #REGISTRY="registry.hub.docker.com"
    IMAGE="${REGISTRY}/${BASE_IMAGE}"
    CID=$(docker ps | grep "${IMAGE}" | awk '{print $1}')
    docker pull "${IMAGE}"

    for im in $CID; do
        LATEST=$(docker inspect --format "{{.Id}}" "${IMAGE}")
        RUNNING=$(docker inspect --format "{{.Image}}" $im)
        NAME=$(docker inspect --format '{{.Name}}' $im | sed "s/\///g")
        echo "Latest: ${LATEST}"
        echo "Running: ${RUNNING}"
        if [ "$RUNNING" != "$LATEST" ]; then
            echo "upgrading $NAME"
            docker stop "${NAME}"
            docker rm -f "${NAME}"
            docker start "${NAME}"
        else
            echo "${NAME} up to date"
        fi
    done
}

## source: https://fabianlee.org/2021/04/08/docker-determining-container-responsible-for-largest-overlay-directories/
##
unalias get-largest-docker-image-sizes 1>/dev/null 2>&1 || true
unset -f get-largest-docker-image-sizes || true
function get-largest-docker-image-sizes() {

    SCRIPT_NAME=docker-largest-image-sizes.sh

    RESULTS_FILE_OVERLAY=${SCRIPT_NAME}-overlay.txt
    RESULTS_FILE_MAPPINGS=${SCRIPT_NAME}-mappings.txt
    RESULTS_FILE_FINAL=${SCRIPT_NAME}.txt

    # grab the size and path to the largest overlay dir
    #du /var/lib/docker/overlay2 -h | sort -h | tail -n 100 | grep -vE "overlay2$" > large-overlay.txt
    du -h --max-depth=1 /var/lib/docker/overlay2 | sort -hr | head -100 | grep -vE "overlay2$" >${RESULTS_FILE_OVERLAY}

    # construct mappings of name to hash
    docker inspect $(docker ps -qa) | jq -r 'map([.Name, .GraphDriver.Data.MergedDir]) | .[] | "\(.[0])\t\(.[1])"' | sed 's/\/merged//' >${RESULTS_FILE_MAPPINGS}

    # for each hashed path, find matching container name
    #cat large-overlay.txt | xargs -l bash -c 'if grep $1 docker-mappings.txt; then echo -n "$0 "; fi' > large-overlay-results.txt

    ## https://unix.stackexchange.com/questions/113898/how-to-merge-two-files-based-on-the-matching-of-two-columns
    join -j 2 -o 1.1,2.1,1.2 <(sort -k2 ${RESULTS_FILE_OVERLAY}) <(sort -k2 ${RESULTS_FILE_MAPPINGS}) | sort -h -k1 -r >${RESULTS_FILE_FINAL}

    cat ${RESULTS_FILE_FINAL}

}

unalias explode_ansible_test 1>/dev/null 2>&1 || true
unset -f explode_ansible_test || true
function explode_ansible_test() {
    RECENT=$(find . -name AnsiballZ_\*.py | head -n1) &&
        python3 ${RECENT} explode &&
        cat debug_dir/args | jq '.ANSIBLE_MODULE_ARGS.logging_level = "DEBUG"' >debug_dir/args.json &&
        cp debug_dir/args.json debug_dir/args &&
        cp debug_dir/args.json debug_dir/args.orig.json
}
#function explode_ansible_test() {
#
#  RECENT=$(find . -name \*.py | head -n1) && \
#  python3 ${RECENT} explode && \
#  cat debug_dir/args | jq > debug_dir/args.json && \
#  cp debug_dir/args.json debug_dir/args && \
#  cp debug_dir/args.json debug_dir/args.orig.json
#
#}

unalias ca_get_account_pwd 1>/dev/null 2>&1 || true
unset -f ca_get_account_pwd || true
function ca_get_account_pwd() {

    CYBERARK_API_BASE_URL=${1:-https://cyberark.example.int}
    CA_USERNAME=${2:-casvcacct}
    CA_PASSWORD=${3:-password}
    CA_ACCOUNT_USERNAME=${4:ca_account_username}

    CA_API_TOKEN=$(curl -s --location --request POST ${CYBERARK_API_BASE_URL}/PasswordVault/API/auth/LDAP/Logon \
        --header 'Content-Type: application/json' \
        --data-raw '{
      "username": "'"${CA_USERNAME}"'",
      "password": "'"${CA_PASSWORD}"'",
        "concurrentSession": true
    }' | tr -d '"')

    #  echo "CA_API_TOKEN=${CA_API_TOKEN}"

    CA_ACCOUNT_ID=$(curl -s --location --request GET ${CYBERARK_API_BASE_URL}/PasswordVault/api/Accounts?search=${CA_ACCOUNT_USERNAME} \
        --header "Content-Length: 0" \
        --header 'Authorization: '${CA_API_TOKEN} | jq '.value[0].id' | tr -d '"')

    #  echo "CA_ACCOUNT_ID=${CA_ACCOUNT_ID}"

    ## ref: https://stackoverflow.com/questions/72311554/how-to-use-bash-command-line-to-curl-an-api-with-token-and-payload-as-parameters
    CA_ACCOUNT_PWD=$(curl -s --location --request POST ${CYBERARK_API_BASE_URL}/PasswordVault/api/accounts/${CA_ACCOUNT_ID}/password/retrieve \
        --header "Content-Length: 0" \
        --header 'Authorization: '${CA_API_TOKEN})

    echo "CA_ACCOUNT_PWD=${CA_ACCOUNT_PWD}"

}

function run_pulp_request() {
    local request_url="${1:-https://pulp.media.johnson.int/pulp/api/v3/status/}"
    local user_cred="${PULP_USERNAME}:${PULP_PASSWORD}"

    # Build the curl command as an array
    local curl_command=(
        curl -sSL
        -u "${user_cred}"
        -w '\n%{http_code}'
        "${request_url}"
    )

    # Mask sensitive credentials in stdout log output
    local cmd_string="${curl_command[*]}"
    local curl_cmd_masked
    curl_cmd_masked=$(echo "${cmd_string}" | sed -E \
        -e 's/Authorization: Bearer [^ '\''"]+/Authorization: Bearer [REDACTED]/g' \
        -e 's/Authorization: Basic [^ '\''"]+/Authorization: Basic [REDACTED]/g' \
        -e 's/-u [^[:space:]]+/-u [REDACTED]/g')

    echo "==> ${curl_cmd_masked}"

    # Execute the command array directly
    local response
    local httpResponseCode
    response=$("${curl_command[@]}")

    httpResponseCode=$(echo "${response}" | tail -n1)
    response=$(echo "${response}" | sed '$d') # Remove the status code line from the body

    if [[ -z "${response}" ]] || [[ "${httpResponseCode}" != "200" ]]; then
        echo "run_pulp_request(): Request failed. HTTP Code: ${httpResponseCode}. Response: ${response}" >&2
        return 1
    fi

    echo "${response}" | jq
}

unalias pulp_status_check 1>/dev/null 2>&1 || true
unset -f pulp_status_check || true
function pulp_status_check() {
    local base_url="${1:-https://pulp.media.johnson.int}"
    local status_url="${base_url}/pulp/api/v3/status/"
    local repo_url="${base_url}/pulp/api/v3/repositories/ansible/ansible/"
    local artifacts_url="${base_url}/pulp_ansible/galaxy/default/api/v3/plugin/ansible/content/internal/collections/artifacts"
    local swagger_url="${base_url}/pulp/api/v3/docs/"

    run_pulp_request "${status_url}"
    run_pulp_request "${repo_url}"
    #    run_pulp_request "${artifacts_url}"
    #    run_pulp_request "${swagger_url}"
}

unalias run_shellchecks_apply 1>/dev/null 2>&1 || true
unset -f run_shellchecks_apply || true
function run_shellchecks_apply() {
  fix_shellchecks.py -g "$@" && fix_shellchecks.py -w "$@" && fix_shellchecks.py -g "$@"
}

unalias ssh_packer 1>/dev/null 2>&1 || true
unset -f ssh_packer || true
function ssh_packer() {
    SSH_TARGET=${1} &&
        echo "SSH_TARGET=${SSH_TARGET}" &&
        IFS=@ read SSH_TARGET_CRED SSH_TARGET_HOST <<<${SSH_TARGET} &&
        ssh-keygen -R "${SSH_TARGET_HOST}" &&
        ssh -i "${HOME}/.ssh/${SSH_KEY}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "${SSH_TARGET}"
}

unalias ssh_packer_work 1>/dev/null 2>&1 || true
unset -f ssh_packer_work || true
function ssh_packer_work() {
    SSH_TARGET=${1} &&
        echo "SSH_TARGET=${SSH_TARGET}" &&
        IFS=@ read SSH_TARGET_CRED SSH_TARGET_HOST <<<${SSH_TARGET} &&
        echo "SSH_TARGET_HOST=${SSH_TARGET_HOST}" &&
        ssh-keygen -R "${SSH_TARGET_HOST}" &&
        ssh -i "${HOME}/.ssh/${SSH_ANSIBLE_KEY_WORK}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "${SSH_TARGET}"
}

unalias find_certs_by_serial_number 1>/dev/null 2>&1 || true
unset -f find_certs_by_serial_number || true
function find_certs_by_serial_number() {
    local CERT_SERIAL_NUMBER="${1//:/}"
    local SEARCH_DIR=${2:-"/usr/share/ca-certs/"}
    find "${SEARCH_DIR}" -regextype egrep -regex ".*\.(crt|pem|cer|der)" -not -name "*-key.*" -print0 |
        xargs -0 -I {} sh -c \
            "openssl x509 -in '{}' -noout -serial | grep -q -i 'serial=${CERT_SERIAL_NUMBER}' && echo '{}'"
}

unalias find_chown_nonmatching 1>/dev/null 2>&1 || true
unset -f find_chown_nonmatching || true
function find_chown_nonmatching() {
    local OWNER=${1:-"foobar"}
    local GROUP=${2:-"${OWNER}"}

    # Check if PWD is outside of the user's HOME directory
    if [[ "$PWD" != "$HOME" && "$PWD" != "$HOME"/* ]]; then
        echo "Error: For safety, this command can only be executed inside your HOME directory ($HOME)." >&2
        return 1
    fi
    if [ "${PWD}" == "/" ]; then
        echo "Do not run this at the root directory for more reasons than can be enumerated here"
        exit
    fi

    echo "Show files that will be changed before changing:"
    FIND_CMD="find . \! -user ${OWNER}"
    echo "$FIND_CMD"
    eval "$FIND_CMD"

    read -p "Are you sure you want to change these files above to owner:group ${OWNER}:${GROUP}? " -n 1 -r
    echo # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    FIND_AND_CHOWN_CMD="find . \! -user ${OWNER} -exec chown ${OWNER}:${GROUP} {} \;"
    echo "$FIND_AND_CHOWN_CMD"
    eval "$FIND_AND_CHOWN_CMD"

    echo "finished"
}
