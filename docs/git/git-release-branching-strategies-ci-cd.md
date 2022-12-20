
# Branching Strategies for CI/CD

Back in the bad old days, testing and deploying code used to be a very manual process for software and infrastructure engineers, often resulting in code that was prone to breaking. Often that would lead to live apps going down in Production, which makes the software unreliable for users.

Version control with continuous integration and continuous delivery (CI/CD) is a best practice that helps solve those problems by integrating code into the existing codebase frequently, with testing, linting, and static code analysis automated so the potential for human error is taken out of the equation. This method puts code in users’ hands fast — which means we can find any problems and fix them fast.

One of the key process decisions a team has to make when implementing version control and continuous integration is how to branch off of the main code base for development. Any branching strategy has benefits and drawbacks, and this choice requires careful consideration of the codebase, the team’s workflow, and stakeholders’ needs. In the following examples, we’re assuming there’s a **main** branch with the entire stable codebase, and that merges to this main branch are automatically deployed out to a later environment (Staging, Production, etc.) with CI/CD tools or platforms.

## Release Branching

Release branching is the least ‘continuous’ of the four strategies. In this approach, the product manager (or whoever makes sense for your team) determines what features, bugfixes and tasks will go in a given release; a release, for our purposes, is a stable distribution of software to the users. Then a branch is made for the entire release, let’s say **release-1.6.7**, and all individual work and pull requests are branched off of **release-1.6.7**. When a pull request is approved, it is merged back into **release-1.6.7**. When all the work that is meant to be included in the release is complete, **release-1.6.7** is merged back into **main** and deployed out automatically.

## Benefits of Release Branching

With release branching, all the code that is meant to be deployed together lives on the same branch. This makes it easy to do isolated testing of new behavior, separate from the rest of the codebase or other in-progress work.

When working at a custom software consulting company, release branching can also be useful because it clearly defines what’s live on Production. This approach helps clients understand when it’s ‘go time’ for new features because deployments are pre-planned and concrete.

## Considerations When Using Release Branching

Release branching places a lot of responsibility on the product manager and takes some flexibility and control out of the hands of the software engineers. Without that flexibility, things get tricky when a hotfix (code to fix an urgent bug on Production) has to go out between releases, or while multiple releases are being worked on at once.

Release branching relies on what we call “long-running branches” (ones that don’t get merged or deployed for weeks, months, or longer). Long-running branches are bad news, because code can go stale and cause problems on merge, or can become incompatible. Imagine you branch off for Release 1.6.7 in February, and start working on new features. Meanwhile, several hotfixes are going out — we found a bug in Production that requires a dependency to update. Unless we’re continuously pulling the main branch into the release branch, our release code might be incompatible with that dependency update, and we won’t find out until the end when we try to merge or run full integration tests. Some teams work fine with this workflow; it just requires a lot of manual management of all the branches as changes happen.

## Feature Branching

Feature branching is similar to release branching, except instead of organizing the branches around a release of several features, you create one branch for each individual feature. For example, imagine your team needs to implement the following feature: “As a user, I can log in to the website with my username and password.” Depending on team structure and workflow, that might encompass several tickets or tasks on your project board. As an example:

-   Ticket #1: “As a user I can see a log-in input that asks for my username and password.”
-   Ticket #2: “As a user I can enter my correct username and password, click submit, and be redirected to my profile.”
-   Ticket #3: “As a user I can enter an incorrect username and password, click submit, and see an error message.”

All of this work might be considered part of the same feature, so maybe you create a branch from **main** called **user-log-in**, and all of this ticket work branches off of that **user-log-in** branch.

## Benefits of Feature Branching

Since the code on each branch is only related to one feature, this approach makes it easy to isolate functionality for testing, review, and deployment planning. It’s also an intuitive, easy-to-understand way of working because it’s organized around application behavior as it applies to users.

## Considerations When Using Feature Branching

Though feature branching is closer to ‘continuous’ than release branching, it still can lead to similar problems with long-running branches, since a feature might take a long time to code to completion. That also means it has similar potential for merge conflicts.

## Story or Task Branching

When story branching or task branching, each ticket gets its own branch. This is the strategy we use at Tandem, because we find that it offers us the best mix of continuous merging and safeguards. So again, if you have a feature “As a user, I can log in to the website with my username and password,” and three tickets for each separate piece of behavior, each of those individual tickets would get its own branch. Often, that branch is named after the ticket number in your project management software (think JIRA or Github Issues). If my ticket is for the Integrations Team and it’s ticket number 145, that story branch might be named **INT-145/user\_sees\_log\_in\_form** and it will only encompass the work for that specific ticket.

## Benefits of Story/Task Branching

This strategy mitigates the risk of long-running branches that comes with a release or feature branching approach. Smaller branches with less behavior are easier to code review, QA, and run test suites on. That makes story branching flexible and fast–which ultimately means you can come closer to merging all the time.

## Considerations When Using a Story/Task Branching Strategy

Complex tickets may take a few days between releases (which means long-ish-running branches!), and there still may be merge conflicts. With story/task branching, though, those merge conflicts will likely be easier to resolve than they would be when using release or feature branching, because you’re probably touching less code on a ticket than you would on a full feature.

## Trunk-Based Development: No Branches!

Finally, the strategy that is truest to the core purpose of CI/CD: trunk-based development. This is honestly the scariest thing I’ve ever written: with trunk-based development, everyone commits and pushes to the **main** branch (the core codebase! without any side branches!), and those commits are deployed automatically! So scary!

## Benefits of Trunk-Based Development

Ideally, engineers will only ship things they are completely confident in and _never_ ship broken code. In real life, though, sometimes deadlines, delivery expectations, and the flow of collaboration on a team preclude this. It’s also a pretty unrealistic expectation (never ship broken code?! Have you EVER written something bug-free? I sure haven’t.). With a trunk-based development strategy, every commit is atomic and roll-back-able.

Trunk-based development eliminates the problems hotfixes can cause in the other branching styles, because hotfixes are treated the same as every other commit of code: every commit just gets deployed automatically on merge. You don’t have to maintain a lot of branches since by definition, trunk-based development creates low branch overhead.

With the other strategies, the automated CI test suite sometimes runs every time you make a new commit commits or merge down to a longer-running branch (release or feature branches). But with trunk-based development, you only run the CI suite one time, when you commit to **main;** and then if it passes the tests, it’s gone out to Production! If it works, it works; if it doesn’t work, you can roll one commit back and try again.

## Considerations When Using a Trunk-Based Development Strategy

With a trunk-based approach, software engineers need to be disciplined about only committing when they have run tests locally, feel completely confident, and won’t break the code. A single broken commit will break it for _everybody_. You also need to be able to commit SUPER SPECIFIC behavior that doesn’t rely on anyone else’s work! If you push a change that someone else’s code is relying on, and your code is broken, they’re stuck until you’ve rolled back, fixed, and redeployed. This is NOT a great strategy for medium-sized or big teams that are delivering a lot of code simultaneously, for this exact reason, unless everyone is bought into the methodology, the communication is CRYSTAL clear at ALL times, and expectations on the team are EXTREMELY high. I’m using a lot of caps-characters on purpose, this is an INTENSE coding workflow.

Since engineers need to be much more thoughtful about what they commit and when they commit, they might end up with long-running commits instead of the long-running branches that are risks of the other three strategies. This defeats the purpose of the strategy; the whole point is to avoid long-running undeployed code.

Using a trunk-based development strategy, all stakeholders need to be comfortable with committing atomic changes that are not full features. This makes it a risky choice at a software development consulting company, where clients will end up seeing things that are broken on staging, or that look gross because UI hasn’t been added yet. In the ‘move fast and break things’ culture of some startups, however, this is often less of a concern — especially if they don’t have a Production environment yet!

The scariest consideration for me: what if your hard drive bricks? If you’re using a trunk-based development approach and your computer crashes, anything you haven’t committed or pushed to remote is gone forever. It’s frustrating to lose all that work, and can negatively impact your timeline, budget, and morale.

___

Depending on your team’s risk tolerance and working style, any of these branching strategies could be a good choice. As with everything else in software development, the key is Communication, Communication, and Communication. The whole team needs to be on board with the strategy and constantly communicating expectations, and this is a great topic for team retros, when you should be evaluating what works for the team and what doesn’t. Have you talked about your branching strategy with your team lately?

## Reference

* https://madeintandem.com/blog/branching-strategies-ci-cd/
* 
