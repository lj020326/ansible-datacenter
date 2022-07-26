
# A Practical Guide to Managing Multiple GitHub Accounts

TD; LR — This article is a practical guide to setting up and managing multiple GitHub accounts on the same machine.

At some point in your work life as a software developer, the need to switch between multiple GitHub accounts may arise. This is especially true if you are a freelance developer. Also, It could simply be a desire to have separate GitHub accounts for work-related projects and personal projects.

## Table of Contents

-   [Requirements](#f637)
-   [Create SSH keys](#4373)
-   [Add SSH keys to GitHub account](#bf89)
-   [Create configuration files to manage keys](#a80e)
-   [Save key identities in local machine](#ebae)
-   [Test on GitHub repository](#c8b5)

## Requirements:

-   Two active GitHub accounts
-   A Unix based machine
-   Some knowledge of working with the terminal

## Create SSH keys

Let’s start by creating two separate SSH keys. Open your computer terminal. Proceed and follow the steps below to create and save two separate keys.

```
$ cd ~/.ssh$ ssh-keygen -t rsa -b 4096 -C "your_personal_email@domain.com"  # save as id_rsa_personal$ ssh-keygen -t rsa -b 4096 -C "your_work_email@domain.com"  # save as id_rsa_work
```

Running the above commands will create four (4) files in the `.ssh` directory in your local machine:

```
id_rsa_personalid_rsa_personal.pubid_rsa_workid_rsa_work.pub
```

_NB: The files with the_ `_.pub_` _extension are the public files that you would add to your GitHub account._

## Add SSH keys to GitHub account

Firstly, copy one of the keys you created, say, the personal key by running the command below:

```
$ pbcopy < ~/.ssh/id_rsa_personal.pub
```

Head over to GitHub, log in and follow the steps below to add the newly created key to your GitHub account.

-   Go to `Settings` by clicking on the drop-down icon beside your avatar located at the top right of the navigation bar.
-   Click on the`SSH and GPG keys` link on the navigation by the left.
-   Click on the green `New SSH key` button by the top right.
-   Add a title to identify the key you are about to paste.
-   Paste the personal key in the `key` input field provided. Click on `Add SSH key` and confirm your GitHub password when prompted.

Go through the same steps to add your work SSH key.

## Create configuration files to manage keys

Head back to the `.ssh` folder in your terminal and create a configuration file for your keys using the command below:

```
$ touch config
```

Open and edit the file using nano/vim. I used nano: `$ nano config`

```
# Personal account - default configHost github.com-personal   HostName github.com   User git   IdentityFile ~/.ssh/id_rsa_personal# Work accountHost github.com-work   HostName github.com   User git   IdentityFile ~/.ssh/id_rsa_work
```

To save and exit — `ctr+o` and `ctrl+x` .

To make the process of managing the SSH keys more stress-free, let’s create two `git` configuration files. The first file would be for the global `git` configuration for use in personal projects and the second file would be for work projects.

Launch your terminal. Navigate to the root directory and create the global git configuration file with the content below:

```
$ cd ~$ nano ~/.gitconfig
```

Content:

```
[user]    name = John Doe    email = johndoe@domain.com[includeIf "gitdir:~/work/"]    path = ~/work/.gitconfig
```

_NB: To save and exit —_ `_ctr+o_` _and_ `_ctrl+x_` _._

Create the work specific git config:

```
$ nano ~/work/.gitconfig
```

Content:

```
[user]    email = john.doe@company.com
```

To explain what is going on here a bit. The above configuration uses [Conditional includes](https://git-scm.com/docs/git-config#_conditional_includes) introduced in `git 2.13` to handle multiple configurations.

In order for the `work` configuration to work correctly, we are assuming that you have a directory called `work` which contains all your work-related projects. If this is not the case, feel free to change work configuration to suit your preferences.

## Save key identities in local machine

Remove any previously-stored key identities using the command:

```
$ cd ~$ ssh-add -D
```

Add the newly created key identities:

```
$ ssh-add id_rsa_personal$ ssh-add id_rsa_work
```

Check if the keys were saved correctly using the command:

```
$ ssh-add -l
```

Good job so far 👏🏼👏🏼👏🏼

Proceed to authenticate the keys with GitHub using the commands below:

```
$ ssh -T github.com-personal  # Hi USERNAME! You've successfully authenticated, but GitHub does not provide shell access.$ ssh -T github.com-work  # Hi USERNAME! You've successfully authenticated, but GitHub does   not provide shell access.
```

## Test on GitHub repository

Head back over to your personal GitHub account. Create a new repository with your desired project name, say, `test-ssh`. Follow the steps below to clone the repository, create your first commit and push to GitHub:

```
$ git clone git@github.com-personal:USERNAME/test-ssh.git $ cd test-ssh$ touch index.html$ echo "Hello World" >> index.html$ git add .$ git commit -m 'Add index file'$ git push origin master
```

In this case, you have cloned the project using your personal git configuration which is the default. The same method can be used for your work-related projects. Bear in mind that all work projects need to be in the`work` directory for the `work` git configuration you have set up to work correctly.

Cheers 🥂🥂

Questions? Feedback? Say hello on [Twitter](http://twitter.com/lj020326) or comment below 👇

