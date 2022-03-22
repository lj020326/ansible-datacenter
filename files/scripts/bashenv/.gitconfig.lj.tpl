# This is Git's per-user configuration file.
[user]
#    repositoryformatversion = 0
    filemode = true
#    bare = false
#    logallrefupdates = true
    symlinks = true
#    ignorecase = true

	name = Lee Johnson
	email = lee.james.johnson@gmail.com
# Please adapt and uncomment the following lines:
#	name = Lee Johnson
#	email = ljohnson@Lees-MBP.johnson.int

## ref: https://emacsformacosx.com/tips
[merge]
        tool = ediff
[mergetool "ediff"]
        cmd = emacs --eval \"(ediff-merge-files-with-ancestor \\\"$LOCAL\\\" \\\"$REMOTE\\\" \\\"$BASE\\\" nil \\\"$MERGED\\\")\"

[alias]
	merge-no-edit = !env GIT_EDITOR=: git merge
