
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


I have long held the opinion that you should avoid Git LFS if possible. Since people keeping asking me why, I figured I'd capture my thoughts in a blog post so I have something to refer them to.

Here are my reasons for not using Git LFS.

### Git LFS is a Stop Gap Solution

Git LFS was developed outside the official Git project to fulfill a very real market need that Git didn't/doesn't handle large files very well.

I believe it is inevitable that Git will gain better support for handling of large files, as this seems like a critical feature for a popular version control tool.

If you make this long bet, LFS is only an interim solution and its value proposition disappears after Git has better native support for large files.

LFS as a stop gap solution would be tolerable except for the fact that...

### Git LFS is a One Way Door

The adoption or removal of Git LFS in a repository is an irreversible decision that requires rewriting history and losing your original commit SHAs.

In some contexts, rewriting history is tolerable. In many others, it is an extremely expensive proposition. My experience maintaining version control in professional contexts aligns with the opinion that rewriting history is expensive and should only be considered a measure of last resort. Maybe if tools made it easier to rewrite history without the negative consequences (e.g. GitHub would redirect references to old SHA1 in URLs and API calls) I would change my opinion here. Until that day, the drawbacks of losing history are just too high to stomach for many.

The reason adoption or removal of LFS is irreversible is due to the way Git LFS works. What LFS does is change the blob content that a Git commit/tree references. Instead of the content itself, it stores a pointer to the content. At checkout and commit time, LFS blobs/records are treated specially via a mechanism in Git that allows content to be rewritten as it moves between Git's core storage and its materialized representation. (The same filtering mechanism is responsible for normalizing line endings in text files. Although that feature is built into the core Git product and doesn't work exactly the same way. But the principles are the same.)

Since the LFS pointer is part of the Merkle tree that a Git commit derives from, you can't add or remove LFS from a repo without rewriting existing Git commit SHAs.

I want to explicitly call out that even if a rewrite is acceptable in the short term, things may change in the future. If you adopt LFS today, you are committing to a) running an LFS server forever b) incurring a history rewrite in the future in order to remove LFS from your repo, or c) ceasing to provide an LFS server and locking out people from using older Git commits. I don't think any of these are great options: I would prefer if there were a way to offboard from LFS in the future with minimal disruption. This is theoretically possible, but it requires the Git core product to recognize LFS blobs/records natively. There's no guarantee this will happen. So adoption of Git LFS is a one way door that can't be easily reversed.

### LFS is More Complexity

LFS is more complex for Git end users.

Git users have to install, configure, and sometimes know about the existence of Git LFS. Version control should _just work_. Large file handling should _just work_. End-users shouldn't have to care that large files are handled slightly differently from small files.

The usability of Git LFS is generally pretty good. However, there's an upper limit on that usability as long as LFS exists outside the core Git product. And LFS will likely never be integrated into the core Git product because the Git maintainers know that LFS is only a stop gap solution. They would rather solve large files storage _correctly_ than ~forever carry the legacy baggage of having to support LFS in the core product.

LFS is more complexity for Git server operators as well. Instead of a self-contained Git repository and server to support, you now have to support a likely separate HTTP server to facilitate LFS access. This isn't the hardest thing in the world, especially since we're talking about key-value blob storage, which is arguably a solved problem. But it's another piece of infrastructure to support and secure and it increases the surface area of complexity instead of minimizing it. As a server operator, I would much prefer if the large file storage were integrated into the core Git product and I simply needed to provide some settings for it to _just work_.


## Conclusion

This post summarized reasons to avoid Git LFS. Are there justifiable scenarios for using LFS? Absolutely! If you insist on using Git and insist on tracking many _large_ files in version control, you should definitely consider LFS. (Although, if you are a heavy user of large files in version control, I would consider Plastic SCM instead, as they seem to have the most mature solution for large files handling.)

The main point of this post is to highlight some drawbacks with using Git LFS because Git LFS is most definitely not a magic bullet. If you can stomach the short and long term effects of Git LFS adoption, by all means, use Git LFS. But please make an informed decision either way.


## References:

1. [Git Large File Storage](https://git-lfs.github.com/)
2. [GitHub’s Large File Storage is no panacea for Open Source — quite the opposite](https://medium.com/@megastep/github-s-large-file-storage-is-no-panacea-for-open-source-quite-the-opposite-12c0e16a9a91)
3. [GitHub help - About storage and bandwidth usage](https://help.github.com/articles/about-storage-and-bandwidth-usage/)
4. [Pricing - Bitbucket](https://bitbucket.org/product/pricing?tab=cloud)
5. [Products Full Feature Comparison - GitLab](https://about.gitlab.com/pricing/self-hosted/feature-comparison/)
6. [Current limitations for Git LFS with Bitbucket](https://confluence.atlassian.com/bitbucket/current-limitations-for-git-lfs-with-bitbucket-828781638.html)

