
# No url found for submodule path

A common error found when initiating a deployment is either:

```
fatal: No url found for submodule path 'path/to/submodule'
```

Or:

```
No submodule mapping found in .gitmodules for path 'path/to/submodule'
```

This occurs when the repository is using files cloned from another repository but has had no mapping reference to the source repository created for it. The mapping needs to be added to a .gitmodules file located in the root directory of the repository you are using.

If you aren't aware of using submodules before, check to make sure the most recent commit didn't involve you downloading code from an external source that contains .git metadata in one of the directories.

You can find out how to either map the submodule to its external source or remove it below.

## [](https://www.deployhq.com/support/common-repository-errors/no-url-found-for-submodule#submodule-mapping)Submodule Mapping

To create the mapping reference, enter the following into your .gitmodules file in the root of your repository (if you haven't already, create it):

```
[submodule "path_to_submodule"] 
  path = path_to_submodule 
  url = git://url-of-source/
```

Where `path_to_submodule` is the actual path within your repository (relative to the root directory) where the submodule will be used, and `url-of-source` is the URL of the original repository that contains the submodule's files.

Before you push your fix for the current submodule mapping issue, you can check to ensure that no more exist by running the following command locally:

Please note that if your source repository is private, you will also need to add the project's deployment key to it's `authorized_keys` file (or Deployment Keys on hosting services such as Codebase, Bitbucket, Github or Gitlab), so that DeployHQ can access and deploy that submodule.

Github does have a restriction that only allows a deployment key to be used on a single repository, but they offer a solution whereby you can create a machine user and assign the deployment key to that user, which will then be given access to multiple Github repositories.

More information on this can be found in [Github's documentation](https://developer.github.com/guides/managing-deploy-keys/#machine-users).

Finally, more information on Submodules can be found in the main [Git manual](http://git-scm.com/book/en/Git-Tools-Submodules).

## [](https://www.deployhq.com/support/common-repository-errors/no-url-found-for-submodule#removing-a-submodule)Removing a submodule

In the case that you might wish to remove an unwanted submodule from your repository, run the following command in your local repository, then push the change to the remote:

```
git rm --cached path_to_submodule
```

Where `path_to_submodule` is the path to your submodule.
