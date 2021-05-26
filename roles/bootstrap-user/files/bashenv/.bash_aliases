
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

alias ll='ls -Fla'
alias la='ls -alrt'
alias lld='ll | grep ^d'

alias cdrepos='cd ~/repos'
alias cdansible='cd ~/repos/ansible'
alias cddc='cd ~/repos/ansible/ansible-datacenter'

alias cdk8s='cd ${PYUTILS_DIR}/k8s'
alias cdkolla='cd ${PYUTILS_DIR}/kolla-ansible'
alias cdpyutils='cd ${PYUTILS_DIR}'

alias cddocs='cd ~/repos/techdocs/infrastructure'
alias cddocker='cd ~/repos/docker'
alias cdnode='cd ~/repos/nodejs'
alias cdpython='cd ~/repos/python'
alias cdmeteor='cd ~/repos/meteor'
alias cdreact='cd ~/repos/react-native'
alias cdjava='cd ~/repos/java'
alias cdcpp='cd ~/repos/cpp'
alias cdblog='cd ~/repos/leeblog'

## ref: https://medium.com/@itsromiljain/the-best-way-to-install-node-js-npm-and-yarn-on-mac-osx-4d8a8544987a
alias installyarn='npm install -g yarn'

alias startminishift='minishift start --vm-driver=virtualbox'

alias space="du -h --max-depth=1 --exclude=nfs --exclude=proc --exclude=aufs --exclude=srv --no-dereference | sed 's/^\([0-9].*\)\([G|K|M]\)\(.*\)/\2 \1 \3/' | sort --key=1,2 -n"
alias space1='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference'
alias space2='du -hs --exclude=nfs --exclude=proc --no-dereference * | sort -h'
#alias space3='du --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'
alias space3='du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference | sort -nr | cut -f2- | xargs du -hs'

alias bigbigspace='space| grep ^[0-9]*[G]'
alias bigspace='space| grep ^[0-9]*[MG]'

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
#alias rsyncnew='rsync -arv --no-links --update --progress --exclude=node_modules --exclude=venv /jdrive/media/torrents/completed/new /x/save/movies/; rm /jdrive/media/torrents/completed/new/*'
#alias rsyncmirror='rsync -arv --delete --no-links --update --progress'
alias rsyncmirror='rsync -ahvAE --delete --stats'

alias getbashenv='rsync1 ${PYUTILS_DIR}/scripts/bashenv/.bash* ~/'

alias systemctl-list='systemctl list-unit-files | sort | grep enabled'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias sshsamba1='ssh administrator@samba.johnson.int'
alias sshmedia='ssh administrator@media.johnson.int'
alias sshplex='ssh administrator@plex.johnson.int'
alias sshplex2='ssh administrator@plex2.johnson.int'
alias sshmail='ssh administrator@mail.dettonville.int'
alias sshadmin='ssh administrator@admin.johnson.int'
alias sshnginx='ssh administrator@nginx.johnson.int'
alias sshgroupware='ssh administrator@groupware.johnson.int'
alias sshdocker='ssh administrator@docker0.johnson.int'
alias sshvcenter6='ssh root@vcenter6.johnson.int'
alias sshopenshift='ssh administrator@openshift.johnson.int'
alias sshovirt='ssh root@ovirt.johnson.int'
alias sshnode01='ssh root@node01.johnson.int'
alias sshkubernetes='ssh administrator@kubernetes.johnson.int'
alias sshnas1='ssh administrator@nas1.johnson.int'
alias sshnas2='ssh administrator@nas2.johnson.int'
alias sshalgo='ssh administrator@algotrader.johnson.int'
alias sshwp='ssh administrator@wordpress.johnson.int'

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
alias venv="virtualenv venv"

if [[ "$platform" =~ ^(MSYS|MINGW)$ ]]; then
    echo "setting aliases specific to MSYS/MINGW platform"
    alias venv2="virtualenv --python=/c/apps/python27/python-2.7.13.amd64/python.exe venv"
#    alias venv3="virtualenv --python=/c/apps/python35/python-3.5.4.amd64/python.exe venv"
    alias venv3="virtualenv --python=/c/apps/python36/python-3.6.8.amd64/python.exe venv"
    alias .venv=". ./venv/Scripts/activate"
    alias python="winpty python"

    alias cdcompleted='cd /c/data/media/torrents/completed'
	alias cdmusic='cd /c/data/media/other/music'
	alias cdbooks='cd /c/data/media/other/books'

    #alias getmusic='rsync2 /jdrive/media/other/music/ /c/data/media/other/music/'
    alias getmusic='rsync2 /jdrive/media/torrents/completed/ /c/data/media/other/music/'
	alias getbooks='rsync3 /jdrive/media/torrents/completed/ /c/data/media/other/books/'
	alias getsoftware='rsync3 /jdrive/media/torrents/completed/ /c/data/downloads/software/'

    alias notepad='/c/apps/notepad++/notepad++.exe'
	alias startheroku='heroku local web -f Procfile.windows'
    alias syncjdrive='rsync2 /c/data/* /jdrive/'

    ## Lee@ljlaptop:[Zenkom](master)$ whereis meteor.bat
    ## meteor: /c/Users/Lee/AppData/Local/.meteor/meteor.bat
    ## SET PYTHON=c:\apps\python27\python-2.7.13.amd64\python
    alias meteor='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; meteor.bat'
    alias meteor2='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; cmd //c meteor.bat'
    #alias meteor='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; meteor.bat'
    #alias meteor='PYTHON=c:\apps\python27\python-2.7.13.amd64\python; winpty meteor.bat'
    #alias meteor='winpty meteor.bat'
    #alias meteor-list-depends='for p in `meteor list | grep "^[a-z]" | awk \'{ print $1"@"$2 }\'`; do echo "$p"; meteor show "$p" | grep -E "^  [a-z]"; echo; done'

else  ## linux
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

fi

