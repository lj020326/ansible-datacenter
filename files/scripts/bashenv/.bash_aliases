
local logPrefix=".bash_aliases"
logDebug "configuring shell aliases..."

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
#alias rsync2='rsync -arv --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'
alias rsync2='rsync -arv --no-links --update --progress -exclude={.idea,.git,node_modules,venv}'

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

alias sshesx00='ssh root@esx00.dettonville.int'
alias sshesx01='ssh root@esx01.dettonville.int'
alias sshesx02='ssh root@esx02.dettonville.int'

alias sshmedia='ssh administrator@media.johnson.int'
alias sshplex='ssh administrator@plex.johnson.int'
alias sshplex2='ssh administrator@plex2.johnson.int'
alias sshopenshift='ssh administrator@openshift.johnson.int'

alias sshadmin='ssh administrator@admin.dettonville.int'
alias sshadmin01='ssh administrator@admin01.johnson.int'
alias sshadmin02='ssh administrator@admin02.johnson.int'
alias sshnas1='ssh administrator@nas1.johnson.int'
alias sshnas01='ssh administrator@nas01.johnson.int'
alias sshnas2='ssh administrator@nas2.johnson.int'
alias sshnas02='ssh administrator@nas02.johnson.int'
alias sshsamba='ssh administrator@samba.johnson.int'
alias sshsamba1='ssh administrator@samba1.johnson.int'
alias sshmail='ssh administrator@mail.johnson.int'
alias sshcgminer='ssh root@cgminer.johnson.int'
alias sshminer='ssh root@cgminer.johnson.int'

alias sshalgo='ssh administrator@algotrader.johnson.int'
alias sshwp='ssh administrator@wordpress.johnson.int'
alias sshk8s='ssh administrator@k8s.johnson.int'

#alias sshhost01='ssh root@host01.johnson.int'
#alias sshhost02='ssh root@host02.johnson.int'
#alias sshnode01='ssh root@node01.johnson.int'
#alias sshnode02='ssh root@node02.johnson.int'
alias sshnode01='ssh administrator@node01.johnson.int'
alias sshnode02='ssh administrator@node02.johnson.int'

alias sshcontrol='ssh administrator@control01.johnson.int'
alias sshvcontrol='ssh administrator@vcontrol01.johnson.int'

alias getansiblelog="scp administrator@admin01.johnson.int:/home/administrator/repos/ansible/ansible-datacenter/ansible.log ."

## ref: https://askubuntu.com/questions/20865/is-it-possible-to-remove-a-particular-host-key-from-sshs-known-hosts-file
alias sshclearhostkey='ssh-keygen -R'
alias sshresetkeys="ssh-keygen -R ${TARGET_HOST} && ssh-keyscan -H ${TARGET_HOST}"

alias create-crypt-passwd="openssl passwd -1 "

alias dockernuke='docker ps -a -q | xargs --no-run-if-empty docker rm -f'
alias gethist="history | tr -s ' ' | cut -d' ' -f3-"
alias startheroku='heroku local'

# alias syncbashenv='rsync1 ${ANSIBLE_DC_REPO}/files/scripts/bashenv/msys2/.bash* ~/'
alias syncbashenv="${ANSIBLE_DC_REPO}/files/scripts/bashenv/install_bashrc.sh && .bash"

## see function for more dynamic/robust version of the same shortcut
#alias blastit-="git pull origin && git add . && git commit -am 'updates from ${HOSTNAME}' && git push origin"
#alias blastmain="git pull main && git add . && git commit -am 'updates from ${HOSTNAME}' && git push origin main"
alias blastgithub="git push github"
alias blasthugo="hugo && blastit. && pushd . && cd public && blastit. && popd"

## ref: https://stackoverflow.com/questions/6052005/how-can-you-git-pull-only-the-current-branch
alias gitpullsub="git submodule update --recursive --remote"

## https://stackoverflow.com/questions/24609146/stop-git-merge-from-opening-text-editor
alias gitmerge="git merge-no-edit"

#alias gitpull-='git pull origin'
#alias gitpush-='git push origin'
#alias gitcommitpush-="git add . && git commit -a -m 'updates from ${HOSTNAME}' && git push origin"
#alias gitremovecached-="git rm -r --cached . && git add . && git commit -am 'Remove ignored files' && git push origin"

## ref: https://www.cloudsavvyit.com/13904/how-to-view-commit-history-with-git-log/
alias gitlog="git log --graph --branches --oneline"
alias gitgraph='git log --graph --oneline --decorate'
alias gitrebase="git rebase --interactive HEAD"
alias gitrewind="git reset --hard HEAD && git clean -d -f"


## ref: http://erikaybar.name/git-deleting-old-local-branches/
alias gitcleanupoldlocal="git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D "

## ref: https://stackoverflow.com/questions/1371261/get-current-directory-name-without-full-path-in-a-bash-script
#alias gitaddorigin="git remote add origin ssh://git@gitea.admin.johnson.int:2222/gitadmin/${PWD##*/}.git && git push -u origin master"
alias gitaddorigin="git remote add origin ssh://git@gitea.admin.dettonville.int:2222/infra/${PWD##*/}.git && git push -u origin master"
#alias gitsetupstream="git branch --set-upstream-to=origin/master"

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

if [[ "$platform" =~ ^(MSYS|MINGW32|MINGW64)$ ]]; then
  logDebug "setting aliases specific to MSYS/MINGW platform"

  alias flushdns="ipconfig //flushdns"

  if [[ "${PYTHON_VERSION}" == *"WIN"* ]]; then
      alias python="winpty python"
      alias pip="winpty pip"
  fi
  alias venv2="virtualenv --python=${PYTHON2_BIN_DIR}/python.exe venv"

  alias notepad='/c/apps/notepad++/notepad++.exe'
  alias startheroku='heroku local web -f Procfile.windows'
  alias syncjdrive='rsync2 /c/data/* /j/'

  ## Lee@ljlaptop:[Zenkom](master)$ whereis meteor.bat
  ## meteor: /c/Users/Lee/AppData/Local/.meteor/meteor.bat
  ## SET PYTHON=c:\apps\python27\python-2.7.13.amd64\python
  alias meteor='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; meteor.bat'
  alias meteor2='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; cmd //c meteor.bat'
  #alias meteor='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; meteor.bat'
  #alias meteor='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; winpty meteor.bat'
  #alias meteor='winpty meteor.bat'
  #alias meteor-list-depends='for p in `meteor list | grep "^[a-z]" | awk \'{ print $1"@"$2 }\'`; do echo "$p"; meteor show "$p" | grep -E "^  [a-z]"; echo; done'

  alias choco="cmd //c choco"
  alias vc='cmd //c "C:\Program^ Files^ ^(x86^)\Microsoft^ Visual^ Studio^ 14.0\VC\vcvarsall.bat & bash"'

  # per https://epsil.github.io/blog/2016/04/20/
  alias open='start'

elif [[ "${platform}" == *"DARWIN"* ]]; then
  logInfo "setting aliases for DARWIN env"
  # alias emacs='emacs -q --load "${HOME}/.emacs.d/init.el"'

  ## ref: https://opensource.com/article/19/5/python-3-default-mac
  # alias python=/usr/local/bin/python3
  # alias pip=/usr/local/bin/pip3

  alias editvscodesettings="emacs ${VSCODE_SETTINGS_DIR}/settings.json"

else  ## linux
  # alias venv2="virtualenv --python=/usr/bin/python2.7 venv"
  # alias venv3="virtualenv --python=/usr/bin/python3.5 venv"
  # alias .venv=". ./venv/bin/activate"

  # alias python=/usr/local/bin/python3
  # alias pip=/usr/local/bin/pip3

  ## useful iscsi commands
  alias getiscsi='iscsiadm --mode session -P 3 | grep -i -e attached -e target'

fi

## work related
alias cdworkdocs='cd ~/repos/silex/docs-internal'
alias cdtower='cd /h/Source/Ansible_Tower'
alias cddcc='cd /h/Source/Ansible_Tower/dcc_common'

alias gitaddworkkey="git config core.sshCommand 'ssh -i ~/.ssh/${SSH_KEY_WORK}'"
alias gitaddalsackey="git config core.sshCommand 'ssh -i ~/.ssh/id_ecdsa'"
alias gitclonework="GIT_SSH_COMMAND='ssh -i ~/.ssh/${SSH_KEY_WORK}' git clone"

#alias sshopentlc="ssh -i ~/.ssh/${SSH_KEY_REDHAT} lab-user@studentvm.${RH_VM_GUID}.example.opentlc.com"
alias sshopentlc="ssh -i ~/.ssh/${SSH_KEY_REDHAT} lab-user@${RH_VM_HOST}"
alias sshopentlc-pw="sshpass -p ${RH_USER_PWD} ssh lab-user@${RH_VM_HOST}"
alias sshopentlc-tower='ssh -i ~/.ssh/${SSH_KEY_REDHAT} ljohnson-silexdata.com@control.78cb.example.opentlc.com'

alias sshtest1="ssh -i ~/.ssh/${SSH_KEY_WORK} ${TEST_SSH_ID}@${TEST_HOST1}"
alias sshtest2="ssh -i ~/.ssh/${SSH_KEY_WORK} ${TEST_SSH_ID}@${TEST_HOST2}"

