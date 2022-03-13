#!/bin/bash
# sets up a pre-commit hook to ensure that vault.yaml is encrypted
# source: https://github.com/ironicbadger/compose-secret-mgt/blob/master/git-init.sh
# ref: https://aaron.cc/prevent-unencrypted-ansible-vaults-from-being-pushed-to-git/

# credit goes to nick busey from homelabos for this neat little trick
# https://gitlab.com/NickBusey/HomelabOS/-/issues/355

run_command_wrapper_fn() {
    bad_file=0

    # files_found=$(find . -iname "*credentials*.yml" -o -iname "*secret*.yml" -o -iname "*vault*.yml" -not -path "./venv/*" \( ! -name save \))
    files_found=$(find . \( -name venv -o -name save \) -prune -o \( -name '*credential*.yml' -o -name '*secret*' -o -name '*vault*' \) -not -name "*example*" -not -name "*.j2" -type f -print)
    for f in ${files_found}; do
        if [[ $(head -n1 "$f") != \$ANSIBLE_VAULT* ]]; then
            # echo "ERROR: $(basename "$f") must be encrypted"
            echo "ERROR: ${f} must be encrypted"
            bad_file=1
        fi
    done
    if [[ $bad_file -eq 1 ]]; then
        exit 1
    fi
}

RUN_COMMAND="$(declare -f run_command_wrapper_fn); run_command_wrapper_fn"

if [ -d .git/ ]; then
rm -f .git/hooks/pre-commit
cat <<EOT >> .git/hooks/pre-commit
${RUN_COMMAND}
EOT

fi

chmod +x .git/hooks/pre-commit
