
log_prefix_aliases=".bash_aliases"
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

alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour

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

alias installdevenv="bash -c $(curl -fsSL "${DEVENV_INSTALL_REMOTE_SCRIPT}")"

alias cdrepos='cd ~/repos'
alias cddocs='cd ~/docs'
alias cdtechdocs='cd ~/repos/docs/docs-tech/infrastructure'

alias cddocker='cd ~/repos/docker'
alias cdjenkins='cd ~/repos/jenkins'
alias cdnode='cd ~/repos/nodejs'
alias cdpython='cd ~/repos/python'
alias cdansible='cd ~/repos/ansible'
#alias cddc='cd ~/repos/ansible/ansible-datacenter'
alias cddc="cd ${ANSIBLE_DC_REPO}"
alias cdkube='cd ~/repos/ansible/ansible-kubespray'
alias cdmeteor='cd ~/repos/meteor'
alias cdreact='cd ~/repos/react-native'
alias cdjava='cd ~/repos/java'
alias cdcpp='cd ~/repos/cpp'
alias cdblog='cd ~/repos/leeblog'
alias cdk8s='cd ${PYUTILS_DIR}/k8s'
alias cdkolla='cd ${PYUTILS_DIR}/kolla-ansible'
alias cdpyutils='cd ${PYUTILS_DIR}'

alias .bash=". ~/.bashrc"
alias .k8sh=". ~/.k8sh"

## ref: https://medium.com/@itsromiljain/the-best-way-to-install-node-js-npm-and-yarn-on-mac-osx-4d8a8544987a
alias installyarn='npm install -g yarn'

alias startminishift='minishift start --vm-driver=virtualbox'

alias space='du -h --max-depth=1 --exclude=nfs --exclude=proc --exclude=aufs --exclude=srv --no-dereference | sed '\''s/^\([0-9].*\)\([G|K|M]\)\(.*\)/\2 \1 \3/'\'' | sort --key=1,2 -n'
alias space1='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference'
alias space2='du -hs --exclude=nfs --exclude=proc --no-dereference * | sort -h'
alias space3='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'
#alias space3='du --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'

alias bigbigspace='space| grep ^[0-9]*[G]'
alias bigspace='space| grep ^[0-9]*[MG]'

## ref: https://www.cyberciti.biz/faq/linux-ls-command-sort-by-file-size/
alias sortfilesize='ls -Slhr'

## ref: https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
alias genpwd='openssl rand -base64 8 | md5sum | head -c8;echo'

## https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
## https://www.studytonight.com/linux-guide/how-to-exclude-files-and-directory-using-rsync
alias rsync0='rsync -ar --info=progress2 --links --delete --update'
alias rsync1='rsync -argv --update --progress'
alias rsync2='rsync -arv --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'
alias rsync3='rsync -arv --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv --exclude=save'
#alias rsync2='rsync -arv --no-links --update --progress -exclude={.idea,.git,node_modules,venv}'
#alias rsync3='rsync -arv --no-links --update --progress -exclude={.idea,.git,node_modules,venv,**/save}'

#alias rsyncnew='rsync -arv --no-links --update --progress --exclude=node_modules --exclude=venv /jdrive/media/torrents/completed/new /x/save/movies/; rm /jdrive/media/torrents/completed/new/*'
alias rsyncmirror='rsync -ar --info=progress2 --delete --update'
alias rsyncmirror2='rsync -arv --delete --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'

## ref: https://stackoverflow.com/questions/352098/how-can-i-pretty-print-json-in-a-shell-script
alias prettyjson='python3 -m json.tool'

## ref: https://stackoverflow.com/questions/19551908/finding-duplicate-files-according-to-md5-with-bash
## ref: https://superuser.com/questions/259148/bash-find-duplicate-files-mac-linux-compatible
alias finddupes="find . -not -empty -type f -printf '%s\n' | sort -rn | uniq -d |\
xargs -I{} -n1 find . -type f -size {}c -print0 | xargs -0 md5sum |\
sort | uniq -w32 --all-repeated=separate"

alias systemctl-list='systemctl list-unit-files | sort | grep enabled'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias dnsreset="ipconfig //flushdns"

## ref: https://apple.stackexchange.com/questions/14980/why-are-dot-underscore-files-created-and-how-can-i-avoid-them
alias dot-turd-show="find . -type f -name '._*' -print"
alias dot-turd-rm="find . -type f -name '._*' -print -delete"

alias sshsetupkeyaliases="setup-ssh-key-identities.sh"
alias sshvcenter='ssh root@vcenter7.dettonville.int'
alias sshvcenter7='ssh root@vcenter7.dettonville.int'
alias sshvcenter6='ssh ansible@vcenter.dettonville.int'
alias sshesx00='ssh root@esx00.dettonville.int'
alias sshesx01='ssh root@esx01.dettonville.int'
alias sshesx02='ssh root@esx02.dettonville.int'
alias sshesx10='ssh root@esx10.dettonville.int'
alias sshesx11='ssh root@esx11.dettonville.int'
alias sshpacker="ssh -i ~/.ssh/${SSH_KEY}"

alias sshmedia='ssh administrator@media.johnson.int'
alias sshplex='ssh administrator@plex.johnson.int'
alias sshplex2='ssh administrator@plex2.johnson.int'
alias sshopenshift='ssh administrator@openshift.johnson.int'

alias sshadmin01='ssh administrator@admin01.johnson.int'
alias sshadmin02='ssh administrator@admin02.johnson.int'
alias sshadmin03='ssh administrator@admin03.johnson.int'
alias sshadmin04='ssh administrator@admin04.johnson.int'
alias sshadmin05='ssh administrator@admin05.johnson.int'
alias sshmail='ssh administrator@mail.johnson.int'
alias sshcgminer='ssh root@cgminer.johnson.int'
alias sshminer='ssh root@cgminer.johnson.int'

alias sshalgo='ssh administrator@algotrader.johnson.int'
alias sshwp='ssh administrator@wordpress.johnson.int'
alias sshk8s='ssh administrator@k8s.johnson.int'

alias sshcontrol='ssh administrator@control01.johnson.int'
alias sshvcontrol='ssh administrator@vcontrol01.johnson.int'

alias getansiblelog="scp administrator@admin01.johnson.int:/home/administrator/repos/ansible/ansible-datacenter/ansible.log ."
alias ansible-test-integration="ansible-test-integration.sh"

## ref: https://askubuntu.com/questions/20865/is-it-possible-to-remove-a-particular-host-key-from-sshs-known-hosts-file
alias sshclearhostkey='ssh-keygen -R'
alias sshresetkeys="ssh-keygen -R ${TARGET_HOST} && ssh-keyscan -H ${TARGET_HOST}"

alias create-crypt-passwd="openssl passwd -1 "

alias dockernuke='docker ps -a -q | xargs --no-run-if-empty docker rm -f'
## https://www.howtogeek.com/devops/what-is-a-docker-image-manifest/
## https://github.com/docker/hub-feedback/issues/2043#issuecomment-1161578466
## docker manifest inspect lj020326/centos8-systemd-python:latest | jq .manifests[0].digest
alias dockerdigest='docker manifest inspect'
alias gethist="history | tr -s ' ' | cut -d' ' -f3-"
alias startheroku='heroku local'

alias syncbashenv="${ANSIBLE_DEVELOPER_REPO}/files/scripts/sync-bashenv.sh && source ~/.bashrc"
alias getsitecertinfo="get_site_cert_info.sh"

## see function for more dynamic/robust version of the same shortcut
#alias blastit-="git pull origin && git add . && git commit -am 'updates from ${HOSTNAME}' && git push origin"
#alias blastmain="git pull main && git add . && git commit -am 'updates from ${HOSTNAME}' && git push origin main"
alias blastgithub="git push github"
alias blasthugo="hugo && blastit. && pushd . && cd public && blastit. && popd"

## ref: https://stackoverflow.com/questions/6052005/how-can-you-git-pull-only-the-current-branch
alias gitpullsub="git submodule update --recursive --remote"
alias gitmergesub="git submodule update --remote --merge && blastit"
alias gitresetsub="git submodule deinit -f . && git submodule update --init --recursive --remote"
alias gitgetcomment="getgitcomment"
alias gitgetrequestid="getgitrequestid"

## resolve issue "Fatal: Not possible to fast-forward, aborting"
#alias gitpullrebase="git pull origin <branch> --rebase"
alias gitpullrebase="git pull origin --rebase"

## https://stackoverflow.com/questions/24609146/stop-git-merge-from-opening-text-editor
git config --global alias.merge-no-edit '!env GIT_EDITOR=: git merge'
alias gitmerge="git merge-no-edit"
alias gitmergemain="git fetch --all && git checkout main && gitpull && git checkout master && git merge-no-edit -X theirs main"

## ref: https://stackoverflow.com/questions/40585959/git-pull-x-theirs-doesnt-work
alias gitpulltheirs='git pull -X theirs'
#alias gitpull-='git pull origin'
#alias gitpush-='git push origin'
#alias gitcommitpush-="git add . && git commit -a -m 'updates from ${HOSTNAME}' && git push origin"
#alias gitremovecached-="git rm -r --cached . && git add . && git commit -am 'Remove ignored files' && git push origin"

## ref: https://www.cloudsavvyit.com/13904/how-to-view-commit-history-with-git-log/
alias gitlog="git log --graph --branches --oneline"
alias gitgraph="git log --graph --oneline --decorate"
alias gitgraphall="git log --graph --all --oneline --decorate"
alias gitrebase="git rebase --interactive HEAD"
alias gitrewind="git reset --hard HEAD && git clean -d -f"


## ref: http://erikaybar.name/git-deleting-old-local-branches/
alias gitcleanupoldlocal="git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D "

## ref: https://stackoverflow.com/questions/1371261/get-current-directory-name-without-full-path-in-a-bash-script
#alias gitaddorigin="git remote add origin ssh://git@gitea.admin.johnson.int:2222/gitadmin/${PWD##*/}.git && git push -u origin master"
alias gitaddorigin="git remote add origin ssh://git@gitea.admin.dettonville.int:2222/infra/${PWD##*/}.git && git push -u origin master"

#alias gitsetupstream="git branch --set-upstream-to=origin/master"
alias gitsetupstream="git branch --set-upstream-to=origin/$(git symbolic-ref HEAD 2>/dev/null)"

## make these function so they evaluate at time of exec and not upon shell startup
## Prevent bash alias from evaluating statement at shell start
## ref: https://stackoverflow.com/questions/13260969/prevent-bash-alias-from-evaluating-statement-at-shell-start
#alias gitpull.="git pull origin $(git rev-parse --abbrev-ref HEAD)"
#alias gitpush.="git push origin $(git rev-parse --abbrev-ref HEAD)"
#alias gitsetupstream="git branch --set-upstream-to=origin/$(git symbolic-ref HEAD 2>/dev/null)"

alias gitfold="bash folder.sh fold"
alias gitunfold="bash folder.sh unfold"

alias decrypt="ansible-vault decrypt"
alias vaultdecrypt="ansible-vault decrypt --vault-password-file=~/.vault_pass"
alias vaultencrypt="ansible-vault encrypt --vault-password-file=~/.vault_pass"

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
alias pyenv310="pyenv global 3.10.2"

#    alias venv3="virtualenv --python=/c/apps/python35/python-3.5.4.amd64/python.exe venv"
#    alias venv3="virtualenv --python=/c/apps/python36/python-3.6.8.amd64/python.exe venv"
# alias venv3="virtualenv --python=${PYTHON3_BIN_DIR}/python.exe venv"
alias venv3="python3 -m venv venv"
alias .venv=". ./venv/${VENV_BINDIR}/activate"

alias venvinit="pip install -r requirements.txt"

## ref: https://emacs.stackexchange.com/questions/4253/how-to-start-emacs-with-a-custom-user-emacs-directory
## ref: https://emacs.stackexchange.com/questions/19936/running-spacemacs-alongside-regular-emacs-how-to-keep-a-separate-emacs-d
alias demacs='emacs -q --load "$HOME/.demacs.d/init.el"'
alias spacemacs='emacs -q --load "$HOME/.spacemacs.d/init.el"'

alias fetchimagesfrommarkdown="~/bin/fetch_images_from_markdown.sh"
alias fetchsitesslcert.sh="~/bin/fetch_site_ssl_cert.sh"
alias fetch-and-import-site-certs="~/bin/fetch_and_import_site_cert_pem.sh"

# alias venv2="virtualenv --python=/usr/bin/python2.7 venv"
# alias venv3="virtualenv --python=/usr/bin/python3.5 venv"
# alias .venv=". ./venv/bin/activate"

# alias python=/usr/local/bin/python3
# alias pip=/usr/local/bin/pip3

## useful iscsi commands
alias getiscsi='iscsiadm --mode session -P 3 | grep -i -e attached -e target'
