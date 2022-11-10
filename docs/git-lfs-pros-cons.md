
# Pros and Cons of using Git-LFS

## Use case

Git-LFS is a Git extension that helps in versioning data files. My personal use case for it is to store metadata files, ML model objects, SQL query results, etc. At the moment, I keep these files under directories with names like `out-v1` or `out-2018-05-01`. Or I keep them in a single `data` directory with file names being `model-v1.pkl`, `model-v2.pkl`, etc. This is a hacky (or a crude) approach; similar to how I used to version my code back in university. Once I got introduced to Git, everything changed - programming workflow got way easier. But you cannot add data files to Git. Well, technically you can, but the Git repo may get bloated. Also, most Git-hosting services won’t allow you to push files more than a specific size limit. Git is not designed for storing or versioning binary files. Git-LFS aims to solve (part of) this issue.

Once you setup LFS in a Git repo, you can start tracking particular files with LFS. You can continue to add, commit, pull, push these files like the way you normally do with code. When you push a commit with a LFS tracked file, the file gets sent to the LFS server, as opposed to the Git server. Only the hash of the file will be stored in the git repo. This way, you can continue to use Git like the way you normally do, but now with the additional ability to use it with binary files.

To learn more about Git-LFS, head over to the [project home page](https://git-lfs.github.com/).

## Disadvantages

While Git-LFS is certainly useful, there are few things to consider before moving ahead to use it.

-   ~**Cross-compatibility**: With git, you can, on any day, move from (say) GitHub to any other hosting provider. But you would lose issues and other data specific to GitHub. If you are moving to GitLab, you can move such GH specific information using GitLab’s custom [GitHub importer](https://docs.gitlab.com/ee/user/project/import/github.html) tool. LFS falls into the same bucket. There is a need for such importers to transfer LFS version information between providers. There aren’t any at the moment though (that I know of).~ Edit: Seems like this is indeed possible to do. See “Moving a Git LFS repository between hosts” section in this page https://www.atlassian.com/git/tutorials/git-lfs.
-   **Pricing**: This is more of a GitHub specific issue, but still is important to note as GitHub is the largest Git hosting provider. The issue is GitHub’s peculiar choice to charge users for bandwidth in addition to storage (see references 2 & 3). Note that Bitbucket charges only for storage (along with most other file hosting services).
-   **Implementation issues**: Issues with forks and transfer of ownership (see references 2 & 6)
-   **Real-world usage & popularity**: Git-LFS seems to be not widely used (yet). Also, interest in it seems to be [stagnant](https://trends.google.com/trends/explore?q=git%20lfs). This makes me worry about the future of the protocol.

## References:

1. [Git Large File Storage](https://git-lfs.github.com/)
2. [GitHub’s Large File Storage is no panacea for Open Source — quite the opposite](https://medium.com/@megastep/github-s-large-file-storage-is-no-panacea-for-open-source-quite-the-opposite-12c0e16a9a91)
3. [GitHub help - About storage and bandwidth usage](https://help.github.com/articles/about-storage-and-bandwidth-usage/)
4. [Pricing - Bitbucket](https://bitbucket.org/product/pricing?tab=cloud)
5. [Products Full Feature Comparison - GitLab](https://about.gitlab.com/pricing/self-hosted/feature-comparison/)
6. [Current limitations for Git LFS with Bitbucket](https://confluence.atlassian.com/bitbucket/current-limitations-for-git-lfs-with-bitbucket-828781638.html)

