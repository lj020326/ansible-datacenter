# This is Git's per-user configuration file.
[user]
    filemode = true
    symlinks = true

    name = Lee Johnson
    email = lee.james.johnson@gmail.com

#    ignorecase = true
#    repositoryformatversion = 0
#    bare = false
#    logallrefupdates = true

[includeIf "gitdir:~/repos/team100/"]
   path = ~/repos/team100/.gitconfig

[includeIf "gitdir:~/repos/team101/"]
   path = ~/repos/team101/.gitconfig

## ref: https://emacsformacosx.com/tips
[merge]
    tool = ediff
[mergetool "ediff"]
    cmd = emacs --eval \"(ediff-merge-files-with-ancestor \\\"$LOCAL\\\" \\\"$REMOTE\\\" \\\"$BASE\\\" nil \\\"$MERGED\\\")\"

[alias]
	merge-no-edit = !env GIT_EDITOR=: git merge
