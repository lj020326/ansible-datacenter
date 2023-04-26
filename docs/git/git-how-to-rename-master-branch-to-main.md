
# How to Rename the master branch to main in Git

For the longest time, the default branch in most Git repositories was named "master". Fortunately, many people have become aware that this terminology (even more evident in "master/slave") should be replaced! The tech industry should move to a more inclusive, open culture - and removing language like "master/slave" is an important step in this journey.

In the public discussion, a handful of different alternatives for "master" have popped up, "default" and "primary" being some of them. But the most popular term seems to be "main".

This short article will help you rename "master" in your own Git repositories to "main" (or any other term your team has chosen).

## The Git Cheat Sheet

No need to remember all those commands and parameters: get our popular "Git Cheat Sheet" - for free!

## Renaming the Local master Branch to main

The first step is to rename the "master" branch in your _local_ Git repositories:

```shell
$ git branch -m master main
```

Let's quickly check if this has worked as expected:

```shell
$ git status
On branch main
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

So far, so good! The local branch has been renamed - but we now need to make some changes on the _remote_ repository as well!

## Renaming the Remote master Branch as Well

In the second step, we'll have to _create a new branch_ on the remote named "main" - because Git does not allow to simply "rename" a remote branch. Instead, we'll have to create a new "main" branch and then delete the old "master" branch.

Make sure your current local HEAD branch is still "main" when executing the following command:

```shell
$ git push -u origin main
```

We now have a new branch on the remote named "main". Let's go on and remove the old "master" branch on the remote:

```shell
$ git push origin --delete master
```

Depending on your exact setup, this might have worked and the renaming is successful. In many cases, however, you will see an error message like the following one:

```shell
To https://github.com/gittower/git-crashcourse.git
! [remote rejected]   master (refusing to delete the current branch: refs/heads/master)
error: failed to push some refs to 'https://example@github.com/gittower/git-crashcourse.git'
```

GitHub, like other code-hosting platforms, too, expects you to define a "default" branch - and deleting this is not allowed. Additionally, your old "master" might be set as "protected". You'll need to resolve this before you can go on. Here's how to do this in GitHub:

If you try again now, deleting "master" from the remote repository should be successful:

```shell
$ git push origin --delete master
To https://github.com/gittower/git-crashcourse.git
 - [deleted]           master
```

##### Tip

#### Renaming "master" to "main" in Tower

In case you are using the [Tower Git client](https://www.git-tower.com/?utm_source=learn-website&utm_campaign=git-faq&utm_medium=easy-in-tower&utm_content=git-rename-master-to-main), you can rename branches very easily:

After creating the new "main" branch on the remote, you might then (depending on your Git hosting platform) have to change the "default" branch or remove any "protected" status for "master". You will then be able to delete the old "master" branch on the remote.

## What Your Teammates Have to Do

If other people on your team have local clones of the repository, they will also have to perform some steps on their end:

```shell
# Switch to the "master" branch:
$ git checkout master

# Rename it to "main":
$ git branch -m master main

# Get the latest commits (and branches!) from the remote:
$ git fetch

# Remove the existing tracking connection with "origin/master":
$ git branch --unset-upstream

# Create a new tracking connection with the new "origin/main" branch:
$ git branch -u origin/main
```

In case you're using the [Tower Git client](https://www.git-tower.com/?utm_source=learn-website&utm_campaign=git-faq&utm_medium=easy-in-tower&utm_content=git-rename-master-to-main), your colleagues can simply rename their local "master" branch and then change the tracking connection in the contextual menu:

## Things to Keep in Mind

As you've seen, the process of renaming "master" to "main" isn't terribly complicated.

Keep in mind your toolchain.

The settings for your 
(1) online repo configuration for the HEAD branch location (bitbucket, gitea, gitlab, etc) will likely need to be updated to reflect the new HEAD branch location
(2) as well as any CI/CD tools, such as GitHub Actions, Azure DevOps / Atlassian Bamboo / GitLab CI pipelines, etc.  You must check these tools thoroughly to make sure any specific "origin/master" branch settings that need to be updated in those settings/configurations.

## Reference

- https://www.git-tower.com/learn/git/faq/git-rename-master-to-main/
- 