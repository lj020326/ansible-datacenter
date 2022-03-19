# This is Git's per-user configuration file.
[user]
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

