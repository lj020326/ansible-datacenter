

# How to extract a Jira issue key from your branch name using git_template

This commit hook will extract a Jira issue key from your branch name (you are naming your branches with issue key’s aren’t you?) and append it to all commit messages so that many places across our products can glue commits together with issues.

prepare-commit-msg:
```shell
#!/bin/sh
#
# git prepare-commit-msg hook for automatically prepending an issue key
# from the start of the current branch name to commit messages.

# check if commit is merge commit or a commit ammend
if [ $2 = "merge" ] || [ $2 = "commit" ]; then
    exit
fi
ISSUE_KEY=`git branch | grep -o "\* \(.*/\)*[A-Z]\{2,\}-[0-9]\+" | grep -o "[A-Z]\{2,\}-[0-9]\+"`
if [ $? -ne 0 ]; then
    # no issue key in branch, use the default message
    exit
fi
# issue key matched from branch prefix, prepend to commit message
TEMP=`mktemp /tmp/commitmsg-XXXXX`
(echo "$ISSUE_KEY: $(cat  $1)") > $TEMP
cat $TEMP > $1
```

- [Source](https://bitbucket.org/atlassian/workspace/snippets/qedp7d)
- [Revisions](https://bitbucket.org/atlassian/workspace/snippets/qedp7d/revisions/)

This commit hook will extract a Jira issue key from your branch name (you are naming your branches with issue key’s aren’t you?) and append it to all commit messages so that many places across our products can glue commits together with issues.
    
To use this:

1.  make sure the folder(s) ~/.git\_template/hooks exists
2.  drop this file in there and make sure it’s named prepare-commit-msg
3.  make ~/.git\_template/hooks/prepare-commit-msg executable. (chmod +x)
4.  make sure your ~/.gitconfig contains  
    \[init\]  
    templatedir = ~/.git\_template

Now anytime you checkout a repo OR use `git init` in a directory, the prepare-commit-msg will be copied into your project’s .git/hooks folder.
    
Note: You can safely run `git init` within pre-existing git projects to get the file copied over
    
## Windows

On Windows, it might not be clear where the \`~\` folder is. Ultimately, this folder is where Git creates your user global `.git_config` file. You probably have a global config.
        
`git config --global --list --show-origin` will show you a list of existing config options and where they were found, including the filename.
        
Once you found where your `.git_config` file is, follow the above instructions. I did not need to change the proposed templatedir value in step 4, nor the shebang in the file, but your mileage may vary.
        
___

and… if the script isn’t running, double check your settings for core.hooksPath interfering:  
`git config --show-origin core.hooksPath`
        
## Other considerations
    
Instead of creating a temporary file with `mktemp` I would inline update the draft commit file like this:
    
```
#!/bin/sh
#
# git prepare-commit-msg hook for automatically prepending an issue key
# from the start of the current branch name to commit messages.

# check if commit is merge commit or a commit ammend
if [ $2 = "merge" ] || [ $2 = "commit" ]; then
    exit
fi
ISSUE_KEY=`git branch | grep -o "\* \(.*/\)*[A-Z]\{2,\}-[0-9]\+" | grep -o "[A-Z]\{2,\}-[0-9]\+"`
if [ $? -ne 0 ]; then
    # no issue key in branch, use the default message
    exit
fi
# issue key matched from branch prefix, prepend to commit message
sed -i -e "1s/^/$ISSUE_KEY /" $1

```
    

To add this automatically to hooks I use NPM

```
npm init -y
npm install -D husky jira-prepare-commit-msg

```
    
Then modify `package.json` and add the following



```
{
  "husky": {
    "hooks": {
      "prepare-commit-msg": "jira-prepare-commit-msg"
    }
  },
  "jira-prepare-commit-msg": {
    "messagePattern": "$J $M"
  }
}

```
    

I followed these instructions some time ago but they never seemed to work. So I just gave up and thought I’ll get back to it someday.

But today, for some strange reason I started getting the Jira issue number added to my commit messages.

This turned out to be a big problem though. In this project I am using `commitizen` and `husky`. Husky doesn’t like this because the commit message doesn’t start with one of it’s types (eg ‘feat:’, ‘bug:’, etc).

Just thought I’d let you know. I could probably mess around with the script to get it to put the issue number after the type and I might do that when I have a chance!

## More

Run this command in your terminal. It will copy the “prepare commit msg” script to the proper hooks folder and fix the permission on that folder. Does everything for you. Just run the script and on the next commit you will see the Jira prefix.
    
```
curl https://gist.githubusercontent.com/jared-christensen/f9db573183ba76c12b6125eda6125ebc/raw/e02ab3b97ac930ab5c2ddc343fb54ebddd85ee96/prepare-commit-msg.sh > .git/hooks/prepare-commit-msg && chmod u+x .git/hooks/prepare-commit-msg

```

## Issue when invoking from python

Hello, I am getting the following error when trying to add this to python pre-commit hooks. I have a python script that invokes the above shell script via `subprocess.Popen(["sh", script_path], shell=True)`
    
There are no errors and the shell script exits with status 0. But nothing happens. The message does not get modified. the same shell script works if I put it directly in the .git/hooks folder.

Any ideas on why running via python seems to fail silently?
