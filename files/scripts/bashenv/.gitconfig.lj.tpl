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

## ref: https://emacsformacosx.com/tips
[merge]
    tool = ediff
[mergetool "ediff"]
    cmd = emacs --eval \"(ediff-merge-files-with-ancestor \\\"$LOCAL\\\" \\\"$REMOTE\\\" \\\"$BASE\\\" nil \\\"$MERGED\\\")\"

[alias]
	merge-no-edit = !env GIT_EDITOR=: git merge
