
# What is the difference between a new working tree and a branch?

There _is_ a difference here, and it's significant, but _understanding_ it is tricky. To get there, let's start with this: Git, in the end, is all about _commits_. It's not about _branches_, but _branch names_ help us (and Git) _find_ commits. It's not about _files_ either, although each commit contains files. It's really about the _commits_. So we need to start with what a commit is and what it does for you. Then we'll go on to _branch names_ and how they _find_ commits, and Git's _index_ and your _working tree_. Once we have all of those covered properly, we can introduce `git worktree` and its peculiarities.

## Commits

A commit, in Git, stores two things:

-   It has a full snapshot of _every_ file, frozen for all time, as of the form that file had at the time you told Git to make the snapshot. (We'll see where these files actually come from later: the surprise is that it's not the files you see and work with / on.) These files are stored in a special, read-only, Git-only, compressed and _de-duplicated_ format, that only Git itself can use. The de-duplication takes care of the fact that each _new_ commit usually has mostly the same files as some older, existing commit. Those files literally get shared between commits—which is completely safe, since no part of any commit can ever be altered.
    
-   Besides the snapshot, each commit has some _metadata_. The metadata hold information such as who made the commit and when. You get to put a log message in here as well, explaining _why_ you made the commit, so that someone else—or your future self—can come back and see what you meant to do. (It's a good idea to put in a high level explanation of what was wrong with the previous commit and what this one is doing to improve it, in case you later find a bug. There's no point putting in low-level details about individual changed lines, because `git diff` or `git show` can show that mechanically.) Like the snapshot, this metadata is also frozen for all time—in fact, that's a feature of every internal Git object: none can _ever be changed_, not even by Git itself.
    

Now, to _find_ a commit directly, Git needs to know the commit's _hash ID_. Commit hash IDs are big ugly strings representing a large [hexadecimal](https://en.wikipedia.org/wiki/Hexadecimal) number, which is actually a cryptographic checksum of the contents of the commit. (This is why the contents can't change: changing even a single bit changes the checksum. Git makes sure, during extraction, that the _contents_ still checksum to the _key_ used to find the object. The objects themselves are stored in a [key-value database](https://en.wikipedia.org/wiki/Key%E2%80%93value_database), with the keys being the checksums.)

So, we need some hash ID `H` to look up a commit. The `git log` command shows you the hash IDs (full or abbreviated, depending on what log format you choose). But these things are useless to humans, who often can't tell <sub><sup><code>211eca0895794362184da2be2a2d812d070719d3</code></sup></sub> from <sub><sup><code>21127fa9829da1f7b805e44517970194490567d0</code></sup></sub> for instance. _Git_ can; computers are good at this sort of finicky detail. So each commit, in its metadata, stores the raw hash ID of one or more _earlier_ commits.

Most commits store exactly one earlier-commit hash ID. This makes for a backwards-looking chain of commits. That is, if we know—somehow—that the hash ID of the _latest_ commit on our `master` or `main` branch is `H` (`H` here is standing in for some real, albeit ugly, hash ID), we could give that raw hash ID to `git log`. Git would then look up commit `H`, and commit `H` has, _inside its metadata_, the hash ID of some earlier commit `G`:

```output
          G <-H
```

But `G` is a commit too, so it has metadata. Git can fish the entire commit `G` out of the big database of all commits using the hash ID it just got from `H`, and _that_ metadata stores the hash ID of some still-earlier commit:

```output
... <-F <-G <-H
```

The `git log` command can keep this process up forever, or rather, as long as each commit it finds has some _previous_ commit. The chain finally ends at the beginning of history: at the very first commit, which—being the first commit—does not have a previous commit hash ID in it, because it can't.

Hence, all we need to get started, at least, is to somehow magically know the hash ID of the _latest_ commit `H`. From there, Git can work backwards, one commit at a time. These commits literally _are_ the history, stored in the repository. Each commit has some metadata telling who made it, when, and why; and each commit has the hash ID of the next-earlier commit. Each commit is a full snapshot of the entire set of files as of the time of that commit. And, by _comparing_ any two adjacent commits' content, Git can tell us what _changed_ in that commit. But we do have that one hitch: we need to know the hash ID of the _latest_ commit.

## Branch names

This is where branch names come in. A branch name like `master` or `main` simply holds _one commit hash ID_. The hash ID stored _in_ that name is that of some commit that definitely does exist in the big Git object database, and—by definition—that hash ID tells Git that that commit is the _last_ commit in/on that branch:

```output
...--F--G--H   <-- main
```

Now, just because `H` is the last commit on `main` does not mean that there aren't any commits that might come "after" `H`. For instance, let's now create a new branch name, `develop`, and make it _also point to commit `H`_ for the moment:

```output
...--F--G--H   <-- develop, main
```

No matter which name we give to `git checkout` or `git switch`, Git will extract commit `H`. Both names select commit `H`, after all. In fact, both branches contain the same set of commits. But Git _does_ need to know which _name_ we're using, so let's add a special name, `HEAD`, to these drawings:

```output
...--F--G--H   <-- develop, main (HEAD)
```

Here, `HEAD` is "attached to" `main`. This means we're on branch `main`, using commit `H`. If we run `git checkout develop` or `git switch develop`, Git will switch from commit `H` to commit `H`—that's not much of a switch!—but will now attach `HEAD` to the name `develop`:

```output
...--F--G--H   <-- develop (HEAD), main
```

From here, let's make one _new_ commit. Git will give this new commit a new, universally-unique hash ID.<sup>1</sup> We'll just call it `I`, and draw it in like this:

```output
...--F--G--H   <-- main
            \
             I   <-- develop (HEAD)
```

Commit `I` will point backwards to its previous commit `H`, from which we grew `I`, and—this is the sneaky trick—now Git writes `I`'s hash ID into the _name_ `develop`. This advances the branch. Now `develop` contains commit `I`, as its final commit, along with commits up through `H`; `main` still ends at `H`.

This is how branches grow by making new commits: each time we make a new commit, the _branch name_ advances as well. If we make two commits on `develop`, we get:

```output
...--F--G--H   <-- main
            \
             I--J   <-- develop (HEAD)
```

If we flip back to `main`, and either create a new branch name, or just make commits directly on `main`, we find that the two branches will diverge:

```output
             K--L   <-- main (HEAD)
            /
...--F--G--H
            \
             I--J   <-- develop
```

If we decide that having made those commits directly on `main` is a bad idea, we can now create a _new_ branch to point to `L`:

```output
             K--L   <-- main (HEAD), feature
            /
...--F--G--H
            \
             I--J   <-- develop
```

and then force Git to _move the name `main` back to `H`_ (we'll have to find `H`'s hash ID, perhaps with `git log`; we might then use `git reset --hard` to move `main`):

```output
             K--L   <-- feature
            /
...--F--G--H   <-- main (HEAD)
            \
             I--J   <-- develop
```

What this emphasizes is that branch names _move_. Normally, they move by you adding new commits to the branch, using `git commit`. But you can move them any which way, using `git reset` or `git branch -f` for instance. Git simply _uses_ the branch names to _find the commits_.

(If you move some branch names backwards, some commits can become very hard to find. For instance, suppose we force `develop` back to commit `I`. How will we find commit `J` after that? There are some ways, but it gets messy, so whenever you're forcing a branch name around, you should think carefully first.)

___

<sup>1</sup>"Universally unique" here means that this hash ID not only doesn't occur in _this_ Git repository yet, it also isn't in _any other Git repository_, now, in the past, or in the future! Git doesn't actually have to meet this strong a constraint—the new hash ID need only not-exist in any Git repository that this Git repository will ever "meet", except when the two meeting Gits are sharing _this_ commit—but Git tries to achieve it anyway, since we don't know for sure which Git repositories we'll connect together in the future. This is why hash IDs are so big and ugly. (As it turns out, they're not quite big and ugly _enough_ now. They were in 2005 when Git was first released, but time marches on.)

___

## Git's index and your working tree

I noted several times that the files in _commits_ are all read-only and Git-only and literally unusable. For this reason, when you _check out_ a commit, Git has to _copy these files out_, into a form that your computer can use normally. These copies go into your _working tree_. This is pretty straightforward and easy to understand, really: the commit holds an archive, that has to be de-archived to be used. So `git checkout` or `git switch` does that: it removes the previous checkout, if any, and replaces it with the commit you choose, which is the one some branch name selects.

(In practice, it's actually a lot fancier and more complicated than this. First, to go fast, the checking out process tries not to touch any file it doesn't have to; second, to avoid discarding uncommitted work, it has to check to make sure that none of the files it will remove-and-replace have uncommitted work in them. But "remove the old commit, put in the new one" is fine as a starting model in your head.)

I also mentioned earlier, though, that `git commit` does not actually make the new snapshots from what you have in your working tree. Instead, Git inserts an extra "copy"—in quotes here as I'll explain in a moment—of each file, _between_ the current committed version and your working tree copy. This extra "copy" is in what Git calls, variously, the _index_, or the _staging area_, or—rarely these days—the _cache_. All three names refer to the same thing, which I'm calling "the index" here.

What is in the index—at least initially, right after a fresh check-out—is a pre-compressed-and-de-duplicated "copy" of _each file from the current commit_. Since these are all _in_ the current commit, the index doesn't really contain any actual file copies at all, just references to ready-to-re-commit files.

As you do your work, Git expects you to run `git add` on each file you change in your working tree. When you _do_ run `git add`, Git:

-   checks to see if the file is already in the index: if so, that "copy" gets booted out;
-   compresses and de-duplicates the working tree copy of the file, and puts _that_ into its index.

So any _new_ file is now in the index, and any _updated_ file has its index copy swapped out for the new, ready-to-commit, compressed and de-duplicated data.

When you run `git commit`, Git simply _packages up the index_ to use as the new commit snapshot. This means that the index's role is to act as your _proposed **next** snapshot_. It starts out matching the current commit, but changes as you run `git add`.

This is why one of the names for the index is the _staging area:_ as you update files, you arrange the updated one "on stage", ready to be snapshotted. The copies in your working tree are yours to fuss with, except:

-   when you use `git checkout` or `git switch` to overwrite them due to switching to some other commit;
-   when you use some other Git command to _deliberately_ overwrite them, e.g., to throw away an experiment that didn't work out; and
-   when you use `git add` to tell Git: _copy from working tree back into your index, to make a new copy ready for the next commit_.

The "copies" (pre-de-duplicated) in Git's index are for _Git_ to use in the next commit.

(The index takes on an expanded role during `git merge` operations, though we won't cover that here. This expanded role is why "index" is, maybe, a better name than "staging area". But "staging area" is a fine name for how it works outside this case.)

## Summary so far

-   A _branch name_ selects some particular commit, by virtue of _pointing to_ that commit.
-   Making a new commit causes the _current branch name_ to point to the new commit. The new commit's _parent_ is the commit you had checked out just a moment ago, before you made the new commit; now the new commit is the one you had checked out.
-   The `git checkout` or `git switch` command picks a new branch name and/or commit to check out. (You can pick a raw commit, using _detached HEAD_ mode, but we won't cover that here.) Assuming you use a new branch name, Git will now attach `HEAD` _to_ that branch name, so that becomes the _current branch name_.
-   Each commit has a unique, big ugly hash ID number, and each commit (with the obvious exception of the very first one, and any other so-called _root_ commits) points backwards to its parent. Although we did not cover this here, a _merge commit_ is special in that it points back to two or more parents, instead of just one parent. Each commit—including each merge commit—stores one complete snapshot of all the files that were in Git's index at the time you (or whoever) made the commit.
-   The _working tree_ holds the files that came out of the commit and went into Git's index, and then to the working tree. You now get to modify those files however you like. Until you `git add` them or use some other Git command to replace the working tree content, everything here is yours to play with.

## Adding a work-tree with `git worktree add`

In the above picture, there is:

-   exactly one `HEAD`, which names which branch is the _current checked-out branch_;
-   exactly one _index_; and
-   exactly one _working tree_.

This means that if we are, for instance, in the middle of working on some new feature, and some highly important must-be-fixed-immediately _bug_ comes up, we have to:

-   save away all our in-progress work;
-   switch to the branch that needs the important bug-fix;
-   and hence wreck (a) our train of thought and (b) any work we had going on in our working tree that doesn't get committed, or that takes a long time to compile or whatever.

If that's a problem, we _could_ just clone the source repository again. This gets an entirely separate repository, in which we have all the same _commits_—the hash IDs match up because they are literally _the same_ commits—but we have a new working tree, index, and `HEAD`. But it might be nice if we could avoid having to run `git clone` and throw a lot of disk space and/or networking time and/or whatever other resources it takes at this.

What if we could, without disturbing our _existing_ working tree, just add a _new working tree?_ We'd also need a new _index_ and a new `HEAD` so that this extra working tree could have a _different branch checked out in it_.

This is precisely what `git worktree add` does. We tell Git: _make me a new working tree, and check out some branch in it_. Git makes all three things—the `HEAD`, the index, and the working tree—and does a `git switch` or `git checkout` there to fill _that_ working tree from _that_ commit as selected by that other branch name.

There's an odd-seeming (at first) constraint, though: our new working tree _must be on a different branch_ than our main working tree or any other added working tree. The reason why becomes clearer once you think about how `git commit` automatically _updates_ whichever branch name is checked out. As an exercise, think about what would happen if two working trees both had branch `develop` checked out, and then you made a _new commit_ in one of them. What happens to the files, and Git's index, in the other working tree? (I'll answer that one for you: _nothing_ happens to them.) So then, what happens when you go into that other working tree and try to make another new commit?

Instead of trying to make this all work (one can imagine various ways to make it work), Git simply forbids it entirely, so that the problem can't come up in the first place. So that's why this odd restriction exists. This restriction does not apply to detached-HEAD mode, so added working trees can be in detached HEAD mode on any specific commit, but again, we haven't really covered detached HEAD mode here.

## Answers to some your your specific questions

> I understand that a Git branch is like a new 'branch' in the current working tree.

No: a working tree is just a place for you to do your work. The term _branch_ is ambiguous (see [What exactly do we mean by "branch"?](https://stackoverflow.com/q/25068543/1256452)), in Git, but a _branch name_, like `main` or `develop`, is just a name by which we (and Git) find one specific hash ID. We can make that name point to any commit we like. Each repository has its own names: if I clone your GitHub repository, I have my own branch names. When you clone your GitHub repository, you get your own branch names in your clone. The GitHub repository has _its_ own branch names. None of these names has to match: I can work with your `main` while calling it `niam` locally, if I like (though that would be silly and just make extra work for me).

> The concept of a new working tree in the same repository is that we create a completely new working space/tree (with a separate Main branch).

No: we create a new working tree within our repository clone, but share everything else.<sup>2</sup> In particular, all the _branch names_ are shared. This is all within one clone (one repository).

> I would really appreciate it if you can point to an example (on Github) that the repo consists of more than one working tree so I can study further.

This is literally impossible: first, added work-trees are specific to each clone. Moreover, GitHub repositories are so-called _bare_ repositories, that have no working trees at all (so that no one can do any work directly on GitHub, not that we have logins on GitHub in the first place).

___

<sup>2</sup>Except index and `HEAD` as already enumerated, and also certain work-tree-specific special refs, such as `ORIG_HEAD`, `MERGE_HEAD`, `CHERRY_PICK_HEAD`, and so on. As I write this, it occurs to me that I'm not sure if `FETCH_HEAD` is work-tree-specific, or not. Special refs like that for bisection are also work-tree-specific. The details here are messy and rather ad-hoc; some details were missed in the original implementation.

## Reference

- https://git-scm.com/docs/git-worktree
- https://stackoverflow.com/questions/67995725/what-is-the-difference-between-a-new-working-tree-and-a-branch
- https://dev.to/yankee/practical-guide-to-git-worktree-58o0
- https://stackoverflow.com/questions/69125521/does-one-git-worktree-support-multiple-branches
- https://www.gitkraken.com/learn/git/git-worktree
- https://morgan.cugerone.com/blog/how-to-use-git-worktree-and-in-a-clean-way/
- 