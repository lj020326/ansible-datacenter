#!/bin/bash
# shellcheck disable=SC2139

log_prefix_aliases=".bash_aliases:"
echo "${log_prefix_aliases} configuring shell aliases..."

#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
#
# Default to human readable figures
# alias df='df -h'
# alias du='du -h'
#
# Misc :)
# alias less='less -r'                          # raw control characters

alias whence='type -a'           # where, of a sort
alias grep='grep --color'        # show differences in colour
alias egrep='egrep --color=auto' # show differences in colour
alias fgrep='fgrep --color=auto' # show differences in colour

# ref: https://stackoverflow.com/questions/60756020/print-environment-variables-sorted-by-name-including-variables-with-newlines
alias showenvvars="export -p | sed 's/declare -x //' | sed 's/export //'"
alias showenvvarnames="export -p | sed 's/declare -x //' | sed 's/export //' | cut -d'=' -f1"

#alias timeinteractiveshell='time /usr/local/bin/bash -l -i -c "/usr/bin/env -0" < /dev/null > /dev/null'
alias timeinteractiveshell='time /usr/local/bin/bash -l -i -c "showenvvarnames"'
alias timeloginshell='time /usr/local/bin/bash -l -c "showenvvarnames"'

alias rununits='./run-tests.sh units'
alias runsanity='./run-tests.sh sanity'

alias runshellcheckgit='pre-commit run shellcheck --files $(git ls-files files/scripts/)'
alias runshellchecks="fix_shellchecks.py -g"
#alias fixshellchecks="fix_shellchecks.py -w"
alias fixshellchecks="run_shellchecks_apply"
alias runshellchecksapply="run_shellchecks_apply"

#
# Some shortcuts for different directory listings
# alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
# alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #

alias ll='ls -Fla --color'
alias la='ls -alrt --color'
alias lld='ll | grep ^d'
alias lll='ll | grep ^l'
## ref: https://stackoverflow.com/questions/8513133/how-do-i-find-all-of-the-symlinks-in-a-directory-tree#8513194
alias findlinks="find . -type l"
alias findchown="find_chown_nonmatching"

alias installdevenv="install_dev_env"

alias cdrepos="cd ${HOME}/repos"
alias cddocs="cd ${HOME}/docs"
alias cdtechdocs="cd ${HOME}/repos/docs/docs-tech/infrastructure"
alias cdnvm='cd_nvm'

alias cddocker="cd ${HOME}/docker"

alias cddockerrepo="cd ${HOME}/repos/docker"
alias cddockerhome='cd /home/container-user/docker'
alias cddockermedia='cd /home/media/docker'
alias cdjenkinsrepo="cd ${HOME}/repos/jenkins"
alias cdnoderepo="cd ${HOME}/repos/nodejs"
alias cdpythonrepo="cd ${HOME}/repos/python"
alias cdansiblerepo="cd ${HOME}/repos/ansible"

alias cddc="cd ${ANSIBLE_DATACENTER_REPO}"
alias cddev="cd ${ANSIBLE_DEVELOPER_REPO}"
alias cdkube="cd ${HOME}/repos/ansible/ansible-kubespray"
alias cdmeteor="cd ${HOME}/repos/meteor"
alias cdreact="cd ${HOME}/repos/react-native"
alias cdjava="cd ${HOME}/repos/java"
alias cdcpp="cd ${HOME}/repos/cpp"
alias cdblog="cd ${HOME}/repos/leeblog"
alias cdk8s='cd ${PYUTILS_DIR}/k8s'
alias cdkolla='cd ${PYUTILS_DIR}/kolla-ansible'
alias cdpyutils='cd ${PYUTILS_DIR}'

alias .bash=". ~/.bashrc"
alias .k8sh=". ~/.k8sh"

#alias findzombies="ps aux | awk '$8 ~ /^[Zz]/'"
alias findzombies="ps -A -ostat,ppid,pid,command | grep -e '^[Zz]'"

## ref: https://medium.com/@itsromiljain/the-best-way-to-install-node-js-npm-and-yarn-on-mac-osx-4d8a8544987a
alias installyarn='npm install -g yarn'

alias startminishift='minishift start --vm-driver=virtualbox'

alias space='du -h --max-depth=1 --exclude=nfs --exclude=proc --exclude=aufs --exclude=srv --apparent-size --no-dereference | sed '\''s/^\([0-9].*\)\([G|K|M]\)\(.*\)/\2 \1 \3/'\'' | sort --key=1,2 -n'
## ref: https://askubuntu.com/questions/5444/how-to-find-out-how-much-disk-space-is-remaining
alias space0='ncdu -x'
alias space1='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference --apparent-size'
#alias space1='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference'
alias space2='du -hs --exclude=nfs --exclude=proc --no-dereference * | sort -h'
alias space3='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'
#alias space3='du --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'

alias bigbigspace='space| grep ^[0-9]*[G]'
alias bigspace='space| grep ^[0-9]*[MG]'

## ref: https://www.cyberciti.biz/faq/linux-ls-command-sort-by-file-size/
alias sortfilesize='ls -Slhr'

## ref: https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
alias genpwd='openssl rand -hex 32'
alias genpwd8='openssl rand -base64 8 | md5sum | head -c8;echo'
## 256 bits of entropy
alias genpwdhex32='openssl rand -hex 32'
alias genpwd32='openssl rand -base64 32 | md5sum | head -c32;echo'

## ref: https://ioflood.com/blog/openssl-view-certificate/#:~:text=To%20view%20a%20certificate%20using,in%20a%20file%20named%20certificate.
## openssl x509 -text -noout -in certificate.crt
alias getcertinfo="openssl x509 -text -noout -in"
alias getcertfingerprint="get_cert_fingerprint"
alias gethostcertinfo="get_host_cert_info"
alias findcertsbyserialnumber="find_certs_by_serial_number"
alias validatehostcert="validate_host_cert.py"
alias fixchromedns="sudo fix-chrome-dns.sh"

## https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
## https://www.studytonight.com/linux-guide/how-to-exclude-files-and-directory-using-rsync
alias rsync0='rsync -ar --info=progress2 --links --delete --update'
alias rsync1='rsync -arog --info=progress2'
alias rsync2='rsync -arv --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'
alias rsync3='rsync -arv --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv --exclude=save'
#alias rsync2='rsync -arv --no-links --update --progress -exclude={.idea,.git,node_modules,venv}'
#alias rsync3='rsync -arv --no-links --update --progress -exclude={.idea,.git,node_modules,venv,**/save}'
alias rsync4='rsync -argv --update --progress'

alias rsyncisofile="rsync -arP -e'ssh -o StrictHostKeyChecking=no' --rsync-path 'sudo -u root rsync' \
  ~/Downloads/rhel-server-7.9-x86_64-dvd.iso \
  administrator@control01.johnson.int:/data/datacenter/vmware/iso-repos/linux/RedHat/7/"

alias rsync_cacerts="rsync -arog --update -e'ssh -o StrictHostKeyChecking=no' --rsync-path 'sudo -u root rsync' \
  /usr/local/ssl/ \
  administrator@vcontrol01.johnson.int:/usr/local/ssl/"

#alias rsyncnew='rsync -arv --no-links --update --progress --exclude=node_modules --exclude=venv /jdrive/media/torrents/completed/new /x/save/movies/; rm /jdrive/media/torrents/completed/new/*'
alias rsyncmirror='rsync -ar --info=progress2 --delete --update'
alias rsyncmirror2='rsync -arv --delete --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'

## ref: https://stackoverflow.com/questions/352098/how-can-i-pretty-print-json-in-a-shell-script
alias prettyjson='python3 -m json.tool'

## ref: https://stackoverflow.com/questions/19551908/finding-duplicate-files-according-to-md5-with-bash
## ref: https://superuser.com/questions/259148/bash-find-duplicate-files-mac-linux-compatible
alias find_dupe_files="find . -not -empty -type f -printf '%s\n' | sort -rn | uniq -d |\
  xargs -I{} -n1 find . -type f -size {}c -print0 | xargs -0 md5sum |\
  sort | uniq -w32 --all-repeated=separate"

alias find_old_dirs="find . -maxdepth 1 -mtime +14 -type d"
alias delete_old_dirs="find . -maxdepth 1 -mtime +14 -type d | xargs rm -f -r;"
alias clean_old_dirs="find . -maxdepth 1 -mtime +14 -type d | xargs rm -f -r;"

alias find_old_dirs_recursive="find . -mtime +14 -type d"
alias delete_old_dirs_recursive="find . -mtime +14 -type d | xargs rm -f -r;"
alias clean_old_dirs_recursive="find . -mtime +14 -type d | xargs rm -f -r;"

alias find_git_dirs="find . -type d -name '.git' -print"
alias remove_git_dirs="find . -type d -name '.git' | xargs rm -f -r;"

alias systemctl-list='systemctl list-unit-files | sort | grep enabled'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias dnsresetwin="ipconfig //flushdns"

## ref: https://apple.stackexchange.com/questions/14980/why-are-dot-underscore-files-created-and-how-can-i-avoid-them
alias dot-turd-show="find . -type f \( -name '._*' -o -name '.DS_Store' -o -name 'SystemOut.log' \) -print"
alias dot-turd-rm="find . -type f \( -name '._*' -o -name '.DS_Store' -o -name 'SystemOut.log' \) -print -delete"

alias dot-file-show="find . -type f -name '.*' -print"
alias dot-file-rm="find . -type f -name '.*' -print -delete"

alias convertpdf2imagepdf="convert_pdf_to_image_pdf.py"

## DNS alias wrappers around functions
alias dnsresetcache="reset_local_dns"
alias dnsreset="reset_local_dns"
## for ping dns resolution:
##   nslookup and ping use different methods to resolve names.
##   While nslookup talks directly to your DNS server, ping uses the system's standard resolver library (glibc),
##   which checks several local sources before ever asking a DNS server
alias resetnscdcache="nscd -i hosts"

alias rotatesshkey="rotate_ssh_key.py"

alias sshsetupkeyaliases="setup-ssh-key-identities.sh"
alias sshvcenter='ssh root@vcenter7.dettonville.int'
alias sshvcenter7='ssh root@vcenter7.dettonville.int'
alias sshvcenter6='ssh ansible@vcenter.dettonville.int'
alias sshesx00='ssh root@esx00.dettonville.int'
alias sshesx01='ssh root@esx01.dettonville.int'
alias sshesx02='ssh root@esx02.dettonville.int'
alias sshesx03='ssh root@esx03.dettonville.int'
alias sshesx10='ssh root@esx10.dettonville.int'
alias sshesx11='ssh root@esx11.dettonville.int'

## this is a function instead
#alias sshpacker="ssh -i ~/.ssh/${SSH_KEY}"
alias sshpacker="ssh_packer"
alias sshosbuild="ssh osbuild@10.10.100.10"

alias sshpfsense='ssh admin@pfsense.johnson.int'
alias sshdiskstation='ssh administrator@diskstation01.johnson.int'

alias sshgpu='ssh administrator@gpu.johnson.int'
alias sshgpu1='ssh administrator@gpu01.johnson.int'
alias sshgpu2='ssh administrator@gpu02.johnson.int'

alias sshmedia='ssh administrator@media.johnson.int'
alias sshmedia1='ssh administrator@media01.johnson.int'
alias sshmedia2='ssh administrator@media02.johnson.int'

alias sshplex='ssh administrator@plex.johnson.int'
alias sshplex2='ssh administrator@plex2.johnson.int'
alias sshopenshift='ssh administrator@openshift.johnson.int'

alias sshadmin01='ssh administrator@admin01.dettonville.int'
alias sshadmin02='ssh administrator@admin02.dettonville.int'
alias sshadmin03='ssh administrator@admin03.dettonville.int'
alias sshadmin04='ssh administrator@admin04.dettonville.int'
alias sshadmin05='ssh administrator@admin05.dettonville.int'
#alias sshadmin01='ssh administrator@admin01.johnson.int'
#alias sshadmin02='ssh administrator@admin02.johnson.int'
#alias sshadmin03='ssh administrator@admin03.johnson.int'
#alias sshadmin04='ssh administrator@admin04.johnson.int'
#alias sshadmin05='ssh administrator@admin05.johnson.int'
alias sshmail='ssh administrator@mail.johnson.int'

alias sshcgminer='ssh root@cgminer.johnson.int'
alias sshminer='ssh root@cgminer.johnson.int'

## ref: https://www.tecmint.com/enable-debugging-mode-in-ssh/
alias sshdebugadmin01='ssh -v administrator@admin01.johnson.int'

alias sshalgo='ssh administrator@algotrader.johnson.int'
alias sshwp='ssh administrator@wordpress.johnson.int'
alias sshk8s='ssh administrator@k8s.johnson.int'

alias sshcontrol='ssh administrator@control02.johnson.int'
alias sshcontrol1='ssh administrator@control01.johnson.int'
alias sshcontrol2='ssh administrator@control02.johnson.int'
alias sshvcontrol='ssh administrator@vcontrol01.johnson.int'

alias getansiblelog="scp administrator@admin01.johnson.int:/home/administrator/repos/ansible/ansible-datacenter/ansible.log ."
alias ansibletestintegration="ansible-test-integration.sh"
alias ansibledebugvar="ansible_debug_variable"
alias explodeansibletest="explode_ansible_test"
alias ansiblevaultscramble="vault_scrambler.py"
alias ansiblevaultorganize="vault_organizer.py"
alias gitrebaseupstream="git_rebase_upstream"
alias gitbranchdiffs="git_branch_diffs"
alias packagedirorig="package_directory"
alias packagedirsh="package-dir.sh"
alias packagedir="package_dir.py"
alias packagebigdir="package_dir.py --max-subdir-files 400 --max-subdir-lines 40000"
alias packagejavadir="package_java_directory"
alias packagegitdir="package_git_directory"
alias packageansiblerole="package_ansible_role"
alias explodeansiblerole="explode_ansible_role"
alias precommitrunall="pre-commit run --all-files"

alias cagetaccountpwd="ca_get_account_pwd"

## ref: https://askubuntu.com/questions/20865/is-it-possible-to-remove-a-particular-host-key-from-sshs-known-hosts-file
alias sshclearhostkey='ssh-keygen -R'
alias sshresetkeys="ssh_reset_key"

alias create-crypt-passwd="openssl passwd -1 "
alias verifyhtpasswd="verify_htpasswd.py"

alias swarmstatus="swarm_status"
alias swarmrestartsvc="swarm_restart_service"
## ref: https://stackoverflow.com/questions/44811886/restart-one-service-in-docker-swarm-stack/48776759
alias swarmserviceupdate="docker service update --force"
alias dockerservicerestart="docker service update --force"
alias dockerserviceupdate="docker service update --force"

alias dockerstackstat="docker stack ps --filter='desired-state=running' docker_stack"
alias dockerstackps="docker stack ps --filter='desired-state=running' docker_stack"

alias dockerexecsh="docker_exec_sh"
alias dockerexecbash="docker_exec_bash"
alias dockerbash="docker_bash"

## llm utils
alias llmutilsv1="llm-utils.sh"
alias llmutils="llm_utils.py"
alias llmfitchoicescoding="docker exec -it llmfit llmfit recommend --use-case coding --json"
alias llmfitchoicesreasoning="docker exec -it llmfit llmfit recommend --use-case reasoning --json"
alias llmfitchoices="docker exec -it llmfit llmfit recommend --json"

## gpu utilities
alias checknvidiaversion="check_nvidia_version"
alias postmortem="sre-shutdown-postmortem.sh"

## test endpoint connectivity
alias curltest="curl -s -L -o /dev/null -w '%{http_code}\n' --max-time 5"
## to be followed by the [ip/dns] [port]
alias testudp="nc -v -u -z -w 3"
alias testudpvpn="nc -v -u -z -w 3 dettonville.cloud 1194"
alias pingupdvpn="nping --udp -p 1194 dettonville.cloud --count 4"

alias pulpstatuscheck="pulp_status_check"

#------------------
# DOCKER aliases
## ref: https://www.virtualizationhowto.com/2023/11/docker-overlay2-cleanup-5-ways-to-reclaim-disk-space/
alias dockerprune='docker system prune -a -f; docker system df'
alias dockernuke='docker ps -a -q | xargs --no-run-if-empty docker rm -f'
## ref: https://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images#34616890
alias dockerclean='docker container prune -f ; docker image prune -f ; docker network prune -f ; docker volume prune -f'

alias dockersyncimage="docker_sync_image"
alias dockerimagesync="docker_sync_image"

## https://www.howtogeek.com/devops/what-is-a-docker-image-manifest/
## https://github.com/docker/hub-feedback/issues/2043#issuecomment-1161578466
## docker manifest inspect lj020326/centos8-systemd-python:latest | jq .manifests[0].digest
alias dockerdigest='docker manifest inspect'
alias gethist="history | tr -s ' ' | cut -d' ' -f3-"
alias startheroku='heroku local'

# alias syncbashenv='rsync1 ${ANSIBLE_DEVELOPER_REPO}/files/scripts/bashenv/msys2/.bash* ~/'
alias syncbashenv="${ANSIBLE_DEVELOPER_REPO}/sync-bashenv.sh && source ${HOME}/.bashrc"
alias syncpublicbranch="sync-public-branch.sh"
alias getsitecertinfo="get-site-cert-info.sh"

alias redactkeyvalues="redact_key_values.py"
alias redactkeyvalues2="redact-key-values.sh"

## see function for more dynamic/robust version of the same shortcut
#alias blastit-="git pull origin && git add . && git commit -am 'updates from ${HOSTNAME}' && git push origin"
#alias blastmain="git pull main && git add . && git commit -am 'updates from ${HOSTNAME}' && git push origin main"
alias blastgithub="git push github"
alias blasthugo="hugo && blastit. && pushd . && cd public && blastit. && popd"

## where appropriate make git aliases utilize bash functions
## to evaluate references at time of exec and not upon shell startup
## Prevent bash aliases from evaluating references at shell start
## ref: https://stackoverflow.com/questions/13260969/prevent-bash-alias-from-evaluating-statement-at-shell-start

## ref: https://stackoverflow.com/questions/6052005/how-can-you-git-pull-only-the-current-branch
alias gitpullsub="git submodule update --recursive --remote"
alias gitmergesub="git submodule update --remote --merge && blastit"
alias gitresetsub="git submodule deinit -f . && git submodule update --init --recursive --remote"
alias gitgetcomment="getgitcomment"
alias gitgetrequestid="getgitrequestid"
alias gitdeletebranch="gitbranchdelete"
alias gitfetchmaindev="git fetch origin main:main && git fetch origin development:development"
alias gitfetchdev="git fetch origin development:development"
alias gitfetchmain="git fetch origin main:main"
alias gitshortlog="git shortlog --summary --numbered --email"
alias gitlogauthors="git log --pretty=format:'[%h] %cd - Committer: %cn (%ce), Author: %an (%ae)'"
alias gitshowlog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
alias gitshowlogall="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
alias gitresetbranchhistory="git_reset_branch_history"
alias gitresetpublicbranch="git_reset_public_branch"
alias gitshowupstream="git_show_upstream"
alias gitsetupstream="git_set_upstream"
alias gitpull="git_pull"
alias gitpullwork="git_pull_work"
alias gitpullgithub="git_pull_github"
alias gitpush="git_push"
alias gitpushwork="git_push_work"
alias gitpushgithub="git_push_github"
alias gitbranchdelete="git_branch_delete"
alias gitbranchrecreate="git_branch_recreate"
alias gitbranchhist="git_branch_hist"
alias gitrequestid="git_request_id"
alias gitcomment="git_comment"
alias gitcommitpush="git_commit_push"
alias gitremovecached="git_remove_cached"
alias blastit="git_pacp"
alias gitchangecommitmsg="git_change_commit_msg"
alias gitmergebranch="git_merge_branch"
alias gitclonework="git_clone_work"
alias gitupdatesub="git_update_sub"
alias gitreinitrepo="git_reinit_repo"
alias gitfetchauthtest="GIT_SSH_COMMAND=\"ssh -v\" git fetch 2>&1 | grep -E 'Server accepts key|Offering public key'"
alias gittestsshkey="ssh -vT git@github.com 2>&1 | grep -E 'Server accepts key|Offering public key'"
alias gitsshauthtest="gittestsshkey"
alias testgitsshauth="gittestsshkey"

## resolves issue "Fatal: Not possible to fast-forward, aborting"
#alias gitpullrebase="git pull origin <branch> --rebase"
#alias gitpullrebase="git pull origin --rebase"
alias gitpullrebase="git_pull_rebase"

## https://stackoverflow.com/questions/24609146/stop-git-merge-from-opening-text-editor
#git config --global alias.merge-no-edit '!env GIT_EDITOR=: git merge'
alias gitmerge="git merge-no-edit"
alias gitmergemain="git fetch --all && git checkout main && gitpull && git checkout master && git merge-no-edit -X theirs main"

## ref: https://stackoverflow.com/questions/40585959/git-pull-x-theirs-doesnt-work
alias gitpulltheirs='git pull -X theirs'
#alias gitremovecached-="git rm -r --cached . && git add . && git commit -am 'Remove ignored files' && git push origin"
alias gitremovecached-="gitremovecached"

## ref: https://stackoverflow.com/questions/61212/how-do-i-remove-local-untracked-files-from-the-current-git-working-tree
alias gitshowuntracked="git clean -n -d"
alias gitcleanuntracked="git clean -f"

## ref: https://www.cloudsavvyit.com/13904/how-to-view-commit-history-with-git-log/
alias gitlog="git log --graph --branches --oneline"
alias gitgraph="git log --graph --oneline --decorate"
alias gitgraphall="git log --graph --all --oneline --decorate"
alias gitrebase="git rebase --interactive HEAD"
alias gitrewind="git reset --hard HEAD && git clean -d -f"

## ref: http://erikaybar.name/git-deleting-old-local-branches/
alias gitcleanupoldlocal="git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D "

## ref: https://stackoverflow.com/questions/1371261/get-current-directory-name-without-full-path-in-a-bash-script
#alias gitaddorigin="git remote add origin ssh://git@gitea.admin.johnson.int:2222/gitadmin/${PWD##*/}.git && git push -u origin main"
alias gitaddorigin="git remote add origin ssh://git@gitea.admin.dettonville.int:2222/infra/${PWD##*/}.git && git push -u origin main"

## ref: https://stackoverflow.com/questions/9662249/how-to-overwrite-local-tags-with-git-fetch
alias gitfetchtags="git fetch origin --tags --force"
alias gitsynctags="git fetch origin --tags --force --prune"

alias gitremoveremote="bash ensure-git-remote.sh remove"
alias gitremoteadd="bash ensure-git-remote.sh add"
alias gitfetchmain="git fetch origin main:main"
alias gitfetchdevelopment="git fetch origin development:development"

alias syncpublicbranch="${HOME}/bin/sync-public-branch.sh"

alias searchrepokeywords="search_repo_keywords"

alias decrypt="ansible-vault decrypt"
alias vaultdecrypt="ansible-vault decrypt --vault-password-file=~/.vault_pass"
alias vaultencrypt="ansible-vault encrypt --vault-password-file=~/.vault_pass"
alias vaultscramble="vault_scrambler.py"
alias vaultorganize="vault_organizer.py"

alias kubelog='kubectl logs --all-namespaces -f'
alias watchkube='watch -d "kubectl get pods --all-namespaces -o wide"'
alias watchkubetail='watch -d "kubectl get pods --all-namespaces -o wide | tail -n $(($LINES - 2))"'

#alias venv="virtualenv venv"
alias venv="python -m venv venv"
#    alias venv2="virtualenv --python=/c/apps/python27/python-2.7.13.amd64/python.exe venv"
alias venv2="virtualenv --python=${PYTHON2_BIN_DIR}/python venv"

## ref: https://realpython.com/intro-to-pyenv/
## use pyenv to set the python env
## pyenv versions   # to show current installed versions
alias pyenv310="pyenv global 3.13.5"

#    alias venv3="virtualenv --python=/c/apps/python35/python-3.5.4.amd64/python.exe venv"
#    alias venv3="virtualenv --python=/c/apps/python36/python-3.6.8.amd64/python.exe venv"
# alias venv3="virtualenv --python=${PYTHON3_BIN_DIR}/python.exe venv"
alias venv3="python3 -m venv venv"
alias .venv=". ./venv/${VENV_BINDIR}/activate"

alias venvinit="pip install -r requirements.txt"

## python linting
alias mypylint="mypy_lint"

## ref: https://emacs.stackexchange.com/questions/4253/how-to-start-emacs-with-a-custom-user-emacs-directory
## ref: https://emacs.stackexchange.com/questions/19936/running-spacemacs-alongside-regular-emacs-how-to-keep-a-separate-emacs-d
alias demacs='emacs -q --load "$HOME/.demacs.d/init.el"'
alias spacemacs='emacs -q --load "$HOME/.spacemacs.d/init.el"'

alias fetchimagesfrommarkdown="${HOME}/bin/fetch-images-from-markdown.sh"
alias fetchsitesslcert="${HOME}/bin/fetch-site-ssl-cert.sh"
alias fetchstepcarootcacert="${HOME}/bin/fetch-stepca-root-cacert.sh"

## use with host:port
#alias fetch-and-import-site-cert="sudo ${HOME}/bin/fetch-and-import-site-cert-pem.sh"
## use with host:port
alias importsitecerts="sudo ${HOME}/bin/install-cacerts.sh"
alias installcacerts="sudo ${HOME}/bin/install-cacerts.sh"

## use with host:port
alias importsslcerts="sudo ${HOME}/bin/import-ssl-certs.sh"
alias importworksslcerts="sudo ${HOME}/bin/import-worksite-ssl-certs.sh"

#alias syncpythoncerts="sudo ${HOME}/bin/sync-python-certs-with-system-cabundle.sh"
alias verifypythonsslconnection="verify_ssl_connection.py"
alias dockerlogin="docker_login"

alias dockerlogin="docker login -u ${DOCKER_REGISTRY_USERNAME} -p \"${DOCKER_REGISTRY_PASSWORD}\" ${DOCKER_REGISTRY_INTERNAL}"

## useful iscsi commands
alias getiscsi='iscsiadm --mode session -P 3 | grep -i -e attached -e target'
## useful apt commands
alias aptlistupgradableall="apt list --upgradable"
alias aptlistupgradesall="apt list --upgradable"
alias aptlistupgradable="apt list --upgradable 2>/dev/null | grep -vFf <(apt-mark showhold)"
alias aptlistupgrades="apt list --upgradable 2>/dev/null | grep -vFf <(apt-mark showhold)"
alias aptupgradesimulated="apt-get -s upgrade | grep '^Inst'"
