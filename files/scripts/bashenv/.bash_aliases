
local log_prefix=".bash_aliases:"
echo "${log_prefix} configuring shell aliases..."

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

alias cdrepos='cd ~/repos'
alias cddocs='cd ~/repos/techdocs/infrastructure'
alias cddocker='cd ~/repos/docker'
alias cdnode='cd ~/repos/nodejs'
alias cdpython='cd ~/repos/python'
alias cdansible='cd ~/repos/ansible'
alias cddc='cd ~/repos/ansible/ansible-datacenter'
alias cdkube='cd ~/repos/ansible/ansible-kubespray'
alias cdmeteor='cd ~/repos/meteor'
alias cdreact='cd ~/repos/react-native'
alias cdjava='cd ~/repos/java'
alias cdcpp='cd ~/repos/cpp'
alias cdblog='cd ~/repos/leeblog'
alias cdk8s='cd ${PYUTILS_DIR}/k8s'
alias cdkolla='cd ${PYUTILS_DIR}/kolla-ansible'
alias cdpyutils='cd ${PYUTILS_DIR}'

## ref: https://medium.com/@itsromiljain/the-best-way-to-install-node-js-npm-and-yarn-on-mac-osx-4d8a8544987a
alias installyarn='npm install -g yarn'

alias startminishift='minishift start --vm-driver=virtualbox'

alias space='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference'
alias space2='du -hs --exclude=nfs --exclude=proc --no-dereference * | sort -h'
#alias space3='du --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'
alias space3='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'

alias bigbigspace='space| grep ^[0-9]*[G]'
alias bigspace='space| grep ^[0-9]*[MG]'

## ref: https://www.cyberciti.biz/faq/linux-ls-command-sort-by-file-size/
alias sortfilesize='ls -Slhr'

## ref: https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
alias genpwd='openssl rand -base64 8 | md5sum | head -c8;echo'

alias gitpull='git pull origin'

alias gitfold="bash folder.sh fold"
alias gitunfold="bash folder.sh unfold"
## ref: http://erikaybar.name/git-deleting-old-local-branches/
alias gitcleanupoldlocal="git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D "

alias rsync1='rsync -argv --update --progress'
alias rsync2='rsync -arv --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'
alias rsync3='rsync -arv --no-links --update --progress --exclude=node_modules --exclude=venv'
alias rsync4='rsync -arv --no-links --update --progress --exclude=node_modules'

#alias rsyncnew='rsync -arv --no-links --update --progress --exclude=node_modules --exclude=venv /jdrive/media/torrents/completed/new /x/save/movies/; rm /jdrive/media/torrents/completed/new/*'
alias rsyncmirror='rsync -arv --delete --no-links --update --progress --exclude=.idea --exclude=.git --exclude=node_modules --exclude=venv'

alias getbashenv='rsync1 ${PYUTILS_DIR}/scripts/bashenv/.bash* ~/'

## ref: https://stackoverflow.com/questions/19551908/finding-duplicate-files-according-to-md5-with-bash
## ref: https://superuser.com/questions/259148/bash-find-duplicate-files-mac-linux-compatible
alias finddupes="find . -not -empty -type f -printf '%s\n' | sort -rn | uniq -d |\
xargs -I{} -n1 find . -type f -size {}c -print0 | xargs -0 md5sum |\
sort | uniq -w32 --all-repeated=separate"

alias systemctl-list='systemctl list-unit-files | sort | grep enabled'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias sshsamba='ssh administrator@samba.johnson.int'
alias sshsamba1='ssh administrator@samba.johnson.int'
alias sshsamba10='ssh administrator@samba10.johnson.int'
alias sshmedia='ssh administrator@media.johnson.int'
alias sshplex='ssh administrator@plex.johnson.local'
alias sshplex2='ssh administrator@plex2.johnson.local'
alias sshmail='ssh administrator@mail.johnson.local'
alias sshadmin='ssh administrator@admin.johnson.local'
alias sshadmin2='ssh administrator@admin2.johnson.local'
alias sshnginx='ssh administrator@nginx.johnson.local'
alias sshgroupware='ssh administrator@groupware.johnson.local'
alias sshdocker='ssh administrator@docker0.johnson.local'
alias sshvcenter6='ssh root@vcenter6.johnson.local'
alias sshopenshift='ssh administrator@openshift.johnson.local'
alias sshovirt='ssh root@ovirt.johnson.local'
alias sshnas1='ssh administrator@nas1.johnson.local'
alias sshnas2='ssh administrator@nas2.johnson.local'
alias sshalgo='ssh administrator@algotrader.johnson.local'
alias sshweb='ssh administrator@lemp1.johnson.local'
alias sshwp='ssh administrator@wordpress.johnson.local'
alias sshwp4='ssh administrator@wordpress4.johnson.local'
alias sshk8s='ssh administrator@k8s.johnson.local'
alias sshubuntu18='ssh administrator@ubuntu18.johnson.local'

alias sshnode01='ssh root@node01.johnson.local'
alias sshhost01='ssh root@host01.johnson.local'
alias sshnode02='ssh root@node02.johnson.local'
alias sshhost02='ssh root@host02.johnson.local'


## ref: https://askubuntu.com/questions/20865/is-it-possible-to-remove-a-particular-host-key-from-sshs-known-hosts-file
alias sshclearhostkey='ssh-keygen -R'

alias dockernuke='docker ps -a -q | xargs --no-run-if-empty docker rm -f'
alias gethist="history | tr -s ' ' | cut -d' ' -f3-"
alias startheroku='heroku local'

alias blastit="git add . ; git commit -m 'updates' ; git push origin"

alias kubelog='kubectl logs --all-namespaces -f'
alias watchkube='watch -d "kubectl get pods --all-namespaces -o wide"'
alias watchkubetail='watch -d "kubectl get pods --all-namespaces -o wide | tail -n $(($LINES - 2))"'

# per https://epsil.github.io/blog/2016/04/20/
alias open='start'

alias .bash=". ~/.bashrc"
alias .k8sh=". ~/.k8sh"
#alias venv="virtualenv venv"
alias venv="python -m venv venv"

alias venv2="virtualenv --python=/usr/bin/python2.7 venv"
alias venv3="virtualenv --python=/usr/bin/python3.5 venv"
alias .venv=". ./venv/bin/activate"

alias cdcompleted='cd /data/media/torrents/completed'
alias cdmusic='cd /data/media/other/music'
alias cdbooks='cd /data/media/other/books'

alias getmusic='rsync3 /data/media/torrents/completed/ /data/media/other/music/'
alias getbooks='rsync3 /data/media/torrents/completed/ /data/media/other/books/'
alias getsoftware='rsync3 /data/media/torrents/completed/ /data/downloads/software/'

## usefule iscsi commands
alias getiscsi='iscsiadm --mode session -P 3 | grep -i -e attached -e target'


