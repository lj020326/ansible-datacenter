
# How to use git worktree and in a clean way

## A bit of vocabulary

### Repository, working tree and bare repository

When you `init` or `clone` a git repository into a directory, you are, by default, left with 2 entities:

-   The **repository** who takes by default the form of a `.git` directory. It contains all the technical files and directories needed by git to maintain the project's versions.
-   The **working tree** which is all the files and directories that are under version control.

A **bare repository** is a repository without a working tree. It only contains what you would normally find under the `.git` directory.  
It can be used as a remote! Indeed you can clone a repository from a local directory if this last contains a bare instance of a git repository.

### Stash

`stash` is a git command that allows you to record the current state of the working tree and the index and then go back to a clean working tree. These records are stored on a stack that can be visualized with `git stash list`.  
To recover the last record from the stack, run `git stash pop`.

## Setting the scene

If you had never heard about the command `git worktree` before, there is a good chance you think that you can only have one branch or commit checked out at a time.

This belief leads you to this inconvenient situation, when, for instance, you need to abandon your work in progress in one branch,

-   to support a colleague on another branch,
-   address this review comment on your pending pull request,
-   fix this bug spotted on QA stage that is a no go for going live,
-   or worst in case of LIVE outage and that you need to deliver a hotfix as soon as possible.

If the work is not in a state where you would commit it; quite often, if you are aware of the `git stash` command, you would:

1.  stage your work
2.  stash it
3.  check out the branch that need to be worked on
4.  do the work
5.  stage, commit, and push
6.  check out the branch you were formely on
7.  pop the last stashed piece of work

And then only you can proceed with you work.  
Phew, that is a lot of inconvenience.

## git worktree to the rescue

With `git worktree` you can link other working trees to your repository.

Taken we are working on the `new-feature` branch and that we need to abandon the work to create a hotfix for the `main` branch.  
In the Terminal, and from the root of the directory that hosts the current working tree, run:

```
$ git worktree add ../hotfix main
```

This has created a new working tree, checked out to the `main` branch, inside of the directory `../hotfix`.

Now you can move to this directory to create the fix.  
Stage, commit and push.

If you come back to your previous directory, you should still have the `new-feature` branch checked out, and you should be able to resume your work where you left it at. Joy!

At some point you also may want to get rid of the `hotfix` worktree. Then run:

```
$ git worktree remove hotfix
```

If at anytime you want to show the existing worktree for a repository, run:

```
$ git worktree list
```

Adding working trees in the parent or the current directory can quickly become a mess.

## A better working trees organization

I find that an organization like the one below is much more tidy!

```
my-awesome-project
 - git-technical-directory
 - new-feature
 - hotfix
```

**bare repository** and **.git** file to the rescue!

Indeed we can proceed like the following:

```
$ mkdir my-awesome-project
$ cd my-awesome-project

$ git clone --bare git@github.com:myname:my-awesome-project.git .bare

$ echo "gitdir: ./.bare" > .git
```

So far, we created a directory for our project, `cd` into it, clone `my-awesome-project` as a bare repository into a `.bare` directory. This `.bare` directory contains what the `.git` directory contains if we would have gone for a standard `git clone` command.

Where it is executed, the `git` command either refer to a `.git` directory or to a `.git` file. This last needs though to contain a pointer to the repository directory. The pointer is the `gitdir` setting.  
Actually in every directory created by the `git worktree add` command, you can find a `.git` file that contains this `gitdir` setting.

Now it is time to create the 2 worktrees:

```
$ git worktree add new-feature
$ git worktree add hotfix master
```

At this stage our directory looks like:

```
my-awesome-project
 - .bare
 - .git
 - new-feature
 - hotfix
```

This is pretty close from what we were aiming for and much better than this mess:

```
hotfix
my-awesome-project
 - .git
 - .gitignore
 - assets
 - index.html
 - package.json
 ...
 - README.md
```

I hope this `git worktree` is as good breaking news for you as it was for me and that it will improve you git experience.

## Update January 14th, 2022

After using Git worktrees for a few weeks, in the manner described in this blog post, I have noted two inefficiencies.

The good news is that I came up with solutions to cover up for them. You will find them as part of these complementary blog posts:

-   [Workarounds to Git worktree using bare repository and cannot fetch remote branches](https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/)
-   (Coming soon!) Git hook to have a npm based project to install dependencies at checkout

## References

- https://morgan.cugerone.com/blog/how-to-use-git-worktree-and-in-a-clean-way/
- [Git worktree reference](https://git-scm.com/docs/git-worktree) 
- [Git stash reference](https://git-scm.com/docs/git-stash)
- [What is a bare Git repo and why you need them on YouTube](https://www.youtube.com/watch?v=8aZW9mYOxhc)
- [Answer talking about .git file and .git folder on Stackoverflow](https://stackoverflow.com/a/67501784)
- [Git Worktrees Step-By-Step by Alex Russell](https://infrequently.org/2021/07/worktrees-step-by-step/)
