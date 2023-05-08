
# Jenkins2 Pipeline jobs using Groovy code in Jenkinsfile

### Overview

-   [Jenkins2 highlights](#jenkins2-highlights)
    -   [Install Jenkins Pipeline plugin](#install-jenkins-pipeline-plugin)
-   [Create Pipeline item type](#create-pipeline-item-type)
    -   [“Build Triggers”](#build-triggers)
    -   [Discard old builds](#discard-old-builds)
-   [Groovy code](#groovy-code)
    -   [Jenkinsfile from GitHub](#jenkinsfile-from-github)
    -   [Pipeline Groovy](#pipeline-groovy)
    -   [Jenkinsfile format](#jenkinsfile-format)
    -   [Build Now for Stage View](#build-now-for-stage-view)
    -   [Build History](#build-history)
-   [Vary Groovy scripting](#vary-groovy-scripting)
-   [Infrastructure as code](#infrastructure-as-code)
-   [Jenkinsfile vs inline Groovy Scripts](#jenkinsfile-vs-inline-groovy-scripts)
    -   [Imports](#imports)
    -   [Stages](#stages)
    -   [Try Catch to email](#try-catch-to-email)
    -   [Tokenize environment variable](#tokenize-environment-variable)
    -   [Unicode icons](#unicode-icons)
    -   [Color wrapper Stage View](#color-wrapper-stage-view)
    -   [Time stamp wrapper](#time-stamp-wrapper)
    -   [Checkout SCM](#checkout-scm)
-   [Multiple SCM](#multiple-scm)
-   [NodeJS](#nodejs)
    -   [Push changes to Git](#push-changes-to-git)
    -   [Git stash](#git-stash)
    -   [Remote Loader Plugin](#remote-loader-plugin)
-   [Item: Organization Folders](#item-organization-folders)
    -   [Parallel jobs](#parallel-jobs)
    -   [Cause](#cause)
-   [Multi-branch projects](#multi-branch-projects)
-   [Durable Task Plugin](#durable-task-plugin)
    -   [Safe Restart Plugin](#safe-restart-plugin)
    -   [Workspace Cleanup](#workspace-cleanup)
    -   [Discard Old Builds](#discard-old-builds-1)
-   [Monitoring](#monitoring)
-   [Chaining in the Pipeline](#chaining-in-the-pipeline)
    -   [Slack notification REST API](#slack-notification-rest-api)
    -   [IRC notification](#irc-notification)
-   [Code Static Scans](#code-static-scans)
-   [Build using Maven](#build-using-maven)
-   [IntelliJ IDE Auto-complete](#intellij-ide-auto-complete)
    -   [CPS Global Library](#cps-global-library)
-   [Parallel Runs](#parallel-runs)
    -   [Snippet generator](#snippet-generator)
-   [Videos on Jenkins2 Pipeline](#videos-on-jenkins2-pipeline)
-   [Texual info about Pipeline](#texual-info-about-pipeline)
-   [Testing](#testing)
-   [Resources](#resources)
-   [Latest Info about Jenkins](#latest-info-about-jenkins)
-   [More on DevOps](#more-on-devops)

This article describes using Jenkins version 2 for Continuouse Integration (CI) using [Groovy DSL scripts](#Groovy)

This takes a deeper dive than [The Pipeline tutorial](https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md), expanded for production use in an enterprise setting.

## Jenkins2 highlights

This adds more deep-dive details and specifics about Jenkinsfile Groovy coding in [https://jenkins.io/2.0](https://jenkins.io/2.0/) and in [videos](#Videos) ( [Pipeline](https://www.youtube.com/watch?v=emV60CcDVV0&t=49m47s))

Summary of Jenkins2 features: [36:00]

-   [Pipeline item type for new jobs](#Pipeline) (instead of Freestyle)
-   Entire pipeline as text code in SCM (GitHub)
-   [Multiple SCM repositories in each job](#MultipleSCM)
-   Pausable: Jobs can wait for manual user input before continuing
    
-   Jobs share global library to share scripts, functions, variables for DRY (Do not Repeat Yourself) - Reusable components and flow
-   Extendable DSL with loops, logic
    
-   Visualized: Pipeline StageView provides status at-a-glance dashboard and trending
-   [Parallel execution](#ParallelRuns) of arbitrary build states
-   Jobs starting in one agent can switch (be joined) to another (fork/join)
-   Resilient: [Durable tasks](#DurableTaskPlugin) keep running while master restarts [41:33]
-   Resumability: Restart from saved checkpoints (Cloudbees feature)

See [https://anoni.sh/jenkins-pipeline](https://anoni.sh/jenkins-pipeline) and [anoni.sh/pipeline-syntax](https://anoni.sh/pipeline-syntax)

Chris Blackden’s [1.43 hr Building a Modern CI/CD Pipeline with Jenkins](https://app.pluralsight.com/library/courses/building-modern-ci-cd-pipeline-jenkins/table-of-contents) makes use of his [Redis-based Dockerized sample app](https://github.com/devbyaccident/azure-voting-app-redis) with yaml to run within AKS.

1.  [VIDEO](https://app.pluralsight.com/course-player?clipId=f40e709c-ef20-41e4-bd02-b8203021e380): In your GitHub account settings, create a new personal access token (PAT) for a connection to use [https://api.github.com](https://api.github.com/) with just these permissions:
    
    -   admin: repo_hook
    -   repo
    -   repo: status
    
    ### Install Jenkins Pipeline plugin
    
2.  The assumption here is that you have followed [my Jenkins Setup tutorial](https://wilsonmar.github.io/jenkins-setup/) to install the latest version of Jenkins, which went Version 2 April 26, 2016 after over 10 years at v1.
    
3.  Additionally, you have followed [my Jenkins plugins tutorial](https://wilsonmar.github.io/jenkins-plugins/) to install the latest version of Jenkins2 and the **Pipeline** plugin  
    
4.  [VIDEO](https://app.pluralsight.com/course-player?clipId=edc23301-cfc0-4712-956a-bcb2cb27d0fc): Install the “Pipeline” plug-in (in Manage Jenkins, Manage Plugins, Available) at  
    [https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin)
    
    PROTIP: Under the covers, Git clients use [https://developer.github.com/v3/repos/hooks/](https://developer.github.com/v3/repos/hooks/)
    
    ## Create Pipeline item type
    
5.  At the Jenkins Dashboard (root URL for Jenkins), click **New Item**.
    
6.  Type the job name (such as “todos1.java.v01”).
    
    PROTIP: Define a standard naming convention for Jenkins job names. Have the name with more than just the component name. Prefix the name with the overall app and its version (such as “CRM1”). This is so people know where it belongs throughout the organization and publicly.
    
    PROTIP: Large teams use transitory elements (such as “unit_test”, “QA”, “prod”, etc.) when separate teams work on the same assets at different points in the lifecycle. But avoid putting transitory elements in Jenkins job names.
    
    PROTIP: As the last part of a name, specify a version number, staring with “v01”. This would allow simultaneous running of jobs which need to have different configurations.
    
7.  Select **Pipeline** (instead of Freestyle). Click OK.
    
    ![jenkins2 item menu 20160811-650x618-i12.jpg](./img/1ef08a70-5fa9-11e6-9721-24401896ab00.jpg)
    
    ### “Build Triggers”
    
    ![jenkins2 build triggers 20160811-289x521-i12](./img/022c2f7e-5faa-11e6-952f-c66a45820d47.jpg)
    
    The “Build Triggers” section provide a variety of options. Some check boxes are mutually exclusive, such as “Build periodically”.
    

### Discard old builds

Clicking this creates a structure:

## Groovy code

The basic ways to obtain (and change) Groovy code for Pipleline type jobs:

1.  [In a Jenkinsfile](#JenkinsfileGitHub) obtained from GitHub (or other SCM)
    
2.  [Inline code](#InlineCode) is good for learning
    
3.  From the run results screen, click [Replay](#Replay), then dynamically changing code before rerun.
    

___

### Jenkinsfile from GitHub

This is the most typical approach in enterprise settings.

[From github-hooks?]

### Pipeline Groovy

1.  Click “Pipeline” tab to bring that section up.
    
    PROTIP: On Linux CentOS, the default folder Jenkins looks for the Jenkinsfile is (replacing “box2” with your job item name):
    
    ```
    /var/lib/jenkins/workspace/box2@script/Jenkinsfile
    
    ```
    
    Instead of manually clicking through the Jenkins UI, the [Pipeline plugin](https://jenkins.io/solutions/pipeline/) in Jenkins 2 reads a text-based **Jenkinsfile** [Groovy script code](#Groovy) checked into source control.
    
    ### Jenkinsfile format
    
    The Jenkins file used to build the Jenkins.io website is  
    [https://github.com/jenkins-infra/jenkins.io/blob/master/Jenkinsfile](https://github.com/jenkins-infra/jenkins.io/blob/master/Jenkinsfile/)
    
    The first line “shebang” defines the file as a Groovy language script:
    
    ```groovy
    #!/usr/bin/env groovy
    
    ```
    
    In-line Pipeline files do not have a “shebang” because it is supplied internally.
    
2.  Add Groovydoc comments
    
    ```groovy
    /**
            * ReqA Class description
     */
    
    ```
    
    PROTIP: Use of GitHub reduces the need for this, but it’s helpful for special notes.
    
3.  Select from the “try sample” pull down “Hello World” or, alternately, highlight the code below and paste it on the form:
    
    ```groovy
    #!/usr/bin/env groovy
     
    /**
            * Sample Jenkinsfile for Jenkins2 Pipeline
            * from https://github.com/hotwilson/jenkins2/edit/master/Jenkinsfile
            * by wilsonmar@gmail.com 
     */
     
    import hudson.model.*
    import hudson.EnvVars
    import groovy.json.JsonSlurperClassic
    import groovy.json.JsonBuilder
    import groovy.json.JsonOutput
    import java.net.URL
     
    try {
    node {
    stage '\u2776 Stage 1'
    echo "\u2600 BUILD_URL=${env.BUILD_URL}"
     
    def workspace = pwd()
    echo "\u2600 workspace=${workspace}"
     
    stage '\u2777 Stage 2'
    } // node
    } // try end
    catch (exc) {
    /*
     err = caughtError
     currentBuild.result = "FAILURE"
     String recipient = 'infra@lists.jenkins-ci.org'
     mail subject: "${env.JOB_NAME} (${env.BUILD_NUMBER}) failed",
             body: "It appears that ${env.BUILD_URL} is failing, somebody should do something about that",
               to: recipient,
          replyTo: recipient,
     from: 'noreply@ci.jenkins.io'
    */
    } finally {
      
     (currentBuild.result != "ABORTED") && node("master") {
         // Send e-mail notifications for failed or unstable builds.
         // currentBuild.result must be non-null for this step to work.
         step([$class: 'Mailer',
            notifyEveryUnstableBuild: true,
            recipients: "${email_to}",
            sendToIndividuals: true])
     }
     
     // Must re-throw exception to propagate error:
     if (err) {
         throw err
     }
    }
    
    ```
    
    Each line in this sample is explained when the log is shown, below.
    
4.  Click Save for the item screen.
    
    ### Build Now for Stage View
    
5.  Click on “Build Now”.
    
    PROTIP: Only click once on Jenkins links or two executions will result from a double-click.
    
    A sample response:
    
    ![jenkins2 build hello-world-490x277-i38.png](./img/59559492-58b2-11e6-84a1-f1acade300ae.png)
    
    NOTE: Text in headings were specified in state keywords in the Groovy script above.
    
6.  Cursor over one of the “ms” numbers (for milliseconds or thousands of a second) in the green area and click the Log button that appears.
    
    A pop-up appears with the text specified by the echo command within the Groovy script.
    
7.  Click the “X” at the upper-right of the dialog to dismiss it.
    
8.  To remove the menu on the left, click “Full Stage View”.
    
    PROTIP: The “full stage view” will be needed when there are more stages going across the screen.
    
    ### Build History
    
9.  To return to the menu with Build History,  
    click the item/job name in the breadcrumbs or press command+left arrow.
    
10.  Click one of the jobs in the Build History section in [http://…/job/box/5/](https://wilsonmar.github.io/jenkins2-pipeline//http://…/job/box/5/)
    
    Notice the number in the URL corresponds to the number listed.
    
    PROTIP: The time of the run is the server’s time, not your local time on your laptop.
    
11.  Click “Console Output” for log details created from that run.
    
    We now try various other Groovy scripting techniques. But first:
    

## Vary Groovy scripting

The analysis of the Console Log from running the sample Groovy script consists of these topics:

-   [Jenkinsfile vs inline](#Jenkinsfile)
-   [Stages](#Stages)
-   [Imports](#Imports)
-   [Try Catch to email](#TryCatch)
-   [Environment Variables](#EnvVars)
    
-   [Unicode icons](#UnicodeIcons)
-   [Color wrapper](#ColorWarapper)
    
-   [Specific Git URL](#GitURL)
-   [Checkout SCM](#CheckoutSCM)

___

`#!/usr/bin/env groovy` is nickamed the “shebang” to announce that the file is in Groovy-language formatting. PROTIP: This is not needed for in-line scripts, but there in case in case this is copied to a [Jenkinsfile](#Jenkinsfile).

`\**` with two asterisk is the code for [code scanners](#CodeScanners) which extract metadata from comments in all related files to come up with an analysis of the codebase.

`stage` commands are used to separate timings reported in the log.

`\u2776` and `\u2777` are Unicode for a black dot with a 1 and 2 in it, to make “Entering stage” lines faster to find.

`\u2600` is Unicode for a “star” icon to make frequently referenced information faster to find.

Notice that unlike Java code, there are **no semicolons**.

Code between the braces ({ and }) is the **body** of the node step.

We will be going to alter this code in the [next section](#VaryGroovy).

## Infrastructure as code

Having infrastructure defined in text code enables experimentation (using experimental branches).

This improves quality by making use of **code review** features in GitHub.

Having infrastructure specifications in the same repository ensures that changes are automatically reflected.

[https://github.com/jenkinsci/pipeline-examples](https://github.com/jenkinsci/pipeline-examples)

-   Run several repos within an organization within GitHub.

[Jesse on GitHub](https://www.youtube.com/watch?v=emV60CcDVV0&t=1h6m7s)

## Jenkinsfile vs inline Groovy Scripts

Here we want go beyond basic scripts and look at scripts used in **production** (productive) use, which are more complicated/complex than almost all the tutorials on the internet:

-   The Jenkinsfile Groovy script used to build the website [Jenkins.io](https://github.com/jenkins-infra/jenkins.io/blob/master/Jenkinsfile)
    
-   [The Jenkins file used to build FreeBSD](https://github.com/freebsd/freebsd-ci/blob/master/scripts/build/build-test.groovy) by Craig Rodrigues (rodrigc@FreeBSD.org)
    
-   [Jenkinsfile with Maven](https://github.com/Jotschi/maven-release-workflow-test) by [Johannes Schüth](http://jotschi.de/)
    

Lessons from these are provided below.

### Imports

The top set of lines in Jenkinsfile Groovy scripts need to be import statements, if any, to pull in libraries containing functions and methods referenced in the script. Examples:

```groovy
import hudson.model.*
import hudson.EnvVars
import groovy.json.JsonSlurperClassic
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import java.net.URL
   
```

Hudson is the previous name of Jenkins before it forked.

The official documentation page for the Apache Groovy language is  
[http://www.groovy-lang.org/documentation.html#gettingstarted](http://www.groovy-lang.org/documentation.html#gettingstarted)

Groovy was used to build [Gradle](https://gradle.org/) because it can handle larger projects than Maven, which Gradle replaces.

### Stages

![jenkins flow 20160805-574x374-i15.jpg](./img/eab0c64c-5e56-11e6-85a2-4ecbbcbaf364.jpg)

This diagram from Jenkins.io illustrates the flow of work.

### Try Catch to email

NOTE: Groovy is a derivative of Java, so it has Java’s capability to catch (handle) execution **exceptions** not anticipated by the programming code.

Notice that

```groovy
   err = caughtError
   currentBuild.result = "FAILURE"
   
```

[This sample](https://github.com/jenkins-infra/jenkins.io/blob/master/Jenkinsfile/) catch block sends out an email:

```groovy
catch (exc) {
    String recipient = 'infra@lists.jenkins-ci.org'
    mail subject: "${env.JOB_NAME} (${env.BUILD_NUMBER}) failed",
            body: "It appears that ${env.BUILD_URL} is failing, somebody should do something about that",
              to: recipient,
         replyTo: recipient,
            from: 'noreply@ci.jenkins.io'
}
   
```

### Environment Variables #

To add text to actual build page, you can use [Groovy Postbuild plugin](https://wiki.jenkins-ci.org/display/JENKINS/Groovy+Postbuild+Plugin) to execute a groovy script in the Jenkins JVM to checs some conditions and changes accordingly the build result, puts badges next to the build in the build history and/or displays information on the build summary page.

```groovy
def workspace = manager.build.getEnvVars()["WORKSPACE"]
String fileContents = new File('${workspace}/filename.txt').text
manager.createSummary("folder.gif").appendText("${fileContents }")
   
```

TODO: Verify the above works.

TODO: This doesn’t work:

```groovy
    def workspace = manager.build.getEnvVars()["WORKSPACE"]
    env.WORKSPACE = pwd() // present working directory.
    def version = readFile "${env.WORKSPACE}/version.txt"
   
```

EnvInject Plugin

Use the withEnv step to set a variable within a temporary scope:

```groovy
node ('pull'){
  git url: 'https://github.com/jglick/simple-maven-project-with-tests.git'
  withEnv(["PATH+MAVEN=${tool 'M3'}/bin"]) {
    sh 'mvn -B verify'
  }
}
   
```

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/gitcommit/gitcommit.groovy) is an example of doing a Bash shell call to invok git commands on the Git client on Jenkins agent machines. This sends STDOUT output to a file (in workspace) named “GIT_COMMIT”:

```groovy
node {
   // Get SHA1 token for the src folder:
   sh('cd src && git rev-parse HEAD > GIT_COMMIT')
               git_commit=readFile('src/GIT_COMMIT')
   short_commit=git_commit.take(6)
 
   // Get first 6 char. of SHA1 token and use it to retrieve the image docker builds:
   sh 'git rev-parse HEAD > GIT_COMMIT'
   def shortCommit = readFile('GIT_COMMIT').take(6)
   def image = docker.build(jenkinsciinfra/bind.build-${shortCommit})")
}
   
```

The [git rev-parse](https://git-scm.com/docs/git-rev-parse) command is a internal Git utility to parse (pick out) revision/object names from a Git repo. This is done after Git has done a checkout to establish the branch and specific commit because the output is a SHA1 hash of the HEAD such as “2b9a2833bc3c6bc8e7b7344e8178ce98e29ebe4b”.

But not to a Pipeline job. Thus the need for shell commands.

`git_commit.take(6)` extracts the first six characters to create a short SHA, much like what Git does because a smaller number of characters are enough to uniquely identify a specific commit.

[https://docs.docker.com/engine/reference/commandline/build/](https://docs.docker.com/engine/reference/commandline/build/)

Such information was previously exposed to freestyle jobs by the Git plugin exposing [environment variables](https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project#Buildingasoftwareproject-JenkinsSetEnvironmentVariables) set when a Jenkins job executes. The following table contains a list of [all these environment variables](https://github.com/jenkinsci/job-dsl-plugin/wiki/User-Power-Moves#access-the-jenkins-environment-variables):

| Environment Variable | Description |
| --- | --- |
| BUILD_CAUSE | BUILD_CAUSE_USERIDCAUSE |
| BUILD_ID | The current build id, such as "2005-08-22_23-59-59" (YYYY-MM-DD_hh-mm-ss, [defunct](https://issues.jenkins-ci.org/browse/JENKINS-26520) since version 1.597) |
| BUILD_NUMBER | The current build number, such as "153" |
| JOB_NAME | Name of the project of this build. This is the name you gave your job when you first set it up. It's the third column of the Jenkins Dashboard main page. |
| BUILD_TAG | String of jenkins-${JOB_NAME}-${BUILD_NUMBER}. Convenient to put into a resource file, a jar file, etc for easier identification. |
| BUILD_URL  
 | The URL where the results of this build can be found (e.g. [http://buildserver/jenkins/job/MyJobName/666/](http://buildserver/jenkins/job/MyJobName/666/)) |
| EXECUTOR_NUMBER | The unique number that identifies the current executor (among executors of the same machine) that's carrying out this build. This is the number you see in the "build executor status", except that the number starts from 0, not 1. |
| JENKINS_URL | Set to the URL of the Jenkins master that's running the build. This value is used by [Jenkins CLI](https://wilsonmar.github.io/display/JENKINS/Jenkins+CLI "Jenkins CLI") for example |
| HOME | - |
| HUDSON_HOME | - |
| JAVA_HOME | If your job is configured to use a specific JDK, this variable is set to the JAVA_HOME of the specified JDK. When this variable is set, PATH is also updated to have $JAVA_HOME/bin. |
| LANG | - |
| LOGNAME | - |
| NODE_NAME | The name of the node the current build is running on. Equals 'master' for master node. |
| NODE_LABELS | - |
| WORKSPACE | The absolute path of the workspace. |
| GIT_COMMIT  
 | For Git-based projects, this variable contains the Git hash of the commit checked out for the build (like ce9a3c1404e8c91be604088670e93434c4253f03) (all the GIT_\* variables require git plugin)      
 |
| GIT_URL | For Git-based projects, this variable contains the Git url (like git@github.com:user/repo.git or [[https://github.com/user/repo.git](https://github.com/user/repo.git)]) |
| GIT_BRANCH  
 | For Git-based projects, this variable contains the Git branch that was checked out for the build (normally origin/master)  
 |
| CVS_BRANCH | For CVS-based projects, this variable contains the branch of the module. If CVS is configured to check out the trunk, this environment variable will not be set. |
| SVN_REVISION | For Subversion-based projects, this variable contains the revision number of the module. If you have more than one module specified, this won't be set.  
 |
| PWD | - |
| OLDPWD | - |
| SHELL | - |
| TERM | - |
| USER | - |

### Tokenize environment variable

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/github-org-plugin/access-repo-information.groovy) is an example of a Groovy script file “access-repo-information.groovy”.

Like other Groovy files, it has in the first line `#!groovy`.

```groovy
#!groovy
 
    tokens = "${env.JOB_NAME}".tokenize('/')
    org = tokens[0]
    repo = tokens[1]
    branch = tokens[2]
    echo 'account-org/repo/branch=' + org +'/'+ repo +'/'+ branch
   
```

`${env.JOB_NAME}` retrieves environment variable JOB_NAME which contains the Git path “org/repo/branch” among github-organization-plugin jobs.

`tokenize` extracts out text between the slash character specified into an array named “tokens”. It is a [Groovy String method](http://docs.groovy-lang.org/latest/html/api/org/codehaus/groovy/runtime/StringGroovyMethods.html).

___

### Unicode icons

![jenkins2 icons in console output 300x497-i10](./img/7b5f18c6-5aef-11e6-827d-68c5bd14e4c2.jpg)

PROTIP: Putting the same visual mark in both the stage name and echos related to the stage makes them visually easier to identify together.

```
   stage '\u273F Verify 4'
   
```

-   “\\u2776” = ❶
-   “\\u27A1” = ➡
-   “\\u2756” = ❖
-   “\\u273F” = ✿
-   “\\u2795” = ➕
    
-   “\\u2713” = ✓
-   “\\u2705” = ✅
-   “\\u274E” = ❎
-   “\\u2717” = ✗
-   “\\u274C” = ❌
    
-   “\\u2600” = ☀
-   “\\u2601” = ☁
-   “\\u2622” = ☢
-   “\\u2623” = ☣
-   “\\u2639” = ☹
-   “\\u263A” = ☺
    
-   [More icons in the \\u2700 Unicode Digbats block](http://www.fileformat.info/info/unicode/block/dingbats/list.htm).
-   [More icons in the \\u2600 range](http://www.w3schools.com/charsets/ref_utf_symbols.asp)

### Color wrapper Stage View

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/ansi-color-build-wrapper/AnsiColorBuildWrapper.groovy) is an example of adding color in a stage name:

```groovy
    wrap([$class: 'AnsiColorBuildWrapper']) {
        stage "\u001B[31m I'm Red \u2717 \u001B[0m Now not"
    }
   
```

This rather geeky technique uses Unicode “\\u001B” ESCAPE codes followed by ANSI characters:

-   “\\u001B[31m” = RED
-   “\\u001B[30m” = BLACK
-   “\\u001B[32m” = GREEN
-   “\\u001B[33m” = YELLOW
-   “\\u001B[34m” = BLUE
-   “\\u001B[35m” = PURPLE
-   “\\u001B[36m” = CYAN
-   “\\u001B[37m” = WHITE
    
-   “\\u001B[0m” is for RESET

### Time stamp wrapper

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/timestamper-wrapper/timestamperWrapper.groovy) is an example of invoking a build wrapper that adds a time stamp to echo output to the console log :

```groovy
   wrap([$class: 'TimestamperBuildWrapper']) {
      echo "Done"
   }
   
```

### Specific Git URL #

In single-branch contexts, one can download a specific repo from GitHub into Jenkins’s local workspace:

```groovy
node {
   git url: "https://github.com/hotwilson/jenkins2.git", branch: 'master'
   sh 'make all'
}
   
```

CAUTION: The “.git” at the end is necessary in the URL and the repo needs to contain a **Jenkinsfile** (no file extension).

A sample Console response to git url:

```
[Pipeline] git
Cloning the remote Git repository
Cloning repository https://github.com/hotwilson/jenkins2.git
 > git init /var/lib/jenkins/workspace/box2 # timeout=10
Fetching upstream changes from https://github.com/hotwilson/jenkins2.git
 > git --version # timeout=10
 > git -c core.askpass=true fetch --tags --progress https://github.com/hotwilson/jenkins2.git +refs/heads/*:refs/remotes/origin/*
 > git config remote.origin.url https://github.com/hotwilson/jenkins2.git # timeout=10
 > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin.url https://github.com/hotwilson/jenkins2.git # timeout=10
Fetching upstream changes from https://github.com/hotwilson/jenkins2.git
 > git -c core.askpass=true fetch --tags --progress https://github.com/hotwilson/jenkins2.git +refs/heads/*:refs/remotes/origin/*
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision b5f1136a0e55363ff143d6ad5b311f7838d8ad82 (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f b5f1136a0e55363ff143d6ad5b311f7838d8ad82 # timeout=10
 > git branch -a -v --no-abbrev # timeout=10
 > git checkout -b master b5f1136a0e55363ff143d6ad5b311f7838d8ad82
First time build. Skipping changelog.
   
```

Additional response for make not included here.

### Checkout SCM

An example using it:

```groovy
node {
   checkout scm
 
   sh 'git rev-parse HEAD > GIT_COMMIT'
   def shortCommit = readFile('GIT_COMMIT').take(6)
   def image = docker.build(jenkinsciinfra/bind.build-${shortCommit})")
 
   stage 'Deploy'
   image.push()
}
   
```

TODO: See [https://github.com/jenkinsci/workflow-scm-step-plugin#generic-scm-step](https://github.com/jenkinsci/workflow-scm-step-plugin#generic-scm-step)

## Multiple SCM

As described in  
[https://github.com/jenkinsci/workflow-scm-step-plugin](https://github.com/jenkinsci/workflow-scm-step-plugin):

While freestyle projects can use the Multiple SCMs plugin to check out more than one repository, or specify multiple locations in SCM plugins that support that (notably the Git plugin), this support is quite limited.

In a Pipeline type job, you can check out multiple SCMs, of the same or different kinds, in the same or different workspaces, wherever and whenever you like. For example, to check out and build several repositories in parallel, each on its own slave:

```groovy
parallel repos.collectEntries {repo -> [/* thread label */repo, {
    node {
        dir('sources') { // switch to subdir
            git url: "https://github.com/user/${repo}"
            sh 'make all -Dtarget=../build'
        }
    }
}]}
   
```

## NodeJS

To work with NodeJS.

### Push changes to Git

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/push-git-repo/pushGitRepo.Groovy) an example of pushing changes to Git from inside Pipeline.

```groovy
withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'MyID', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD']]) {
    sh("git tag -a some_tag -m 'Jenkins'")
    sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@<REPO> --tags')
}
   
```

This approach requires the repository to be setup in Jenkins to be authenticated to the repo (GitHub) using username and password rather than other methods.

A [open JIRA](https://issues.jenkins-ci.org/browse/JENKINS-28335) requests getting the GitPublisher Jenkins functionality working with Pipeline.

TODO: For SSH private key authentication, try the sshagent step from the SSH Agent plugin.

### Git stash

[This](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/unstash-different-dir/unstashDifferentDir.groovy) script uses the Git stash command to move text among Jenkins nodes.

```groovy
// First we'll generate a text file in a subdirectory on one node and stash it.
stage "first step on first node"
 
// Run on a node with the "first-node" label.
node('first-node') {
    // Make the output directory.
    sh "mkdir -p output"
 
    // Write a text file there.
    writeFile file: "output/somefile", text: "Hey look, some text."
 
    // Stash that directory and file.
    // Note that the includes could be "output/", "output/*" as below, or even
    // "output/**/*" - it all works out basically the same.
    stash name: "first-stash", includes: "output/*"
}
 
// Next, we'll make a new directory on a second node, and unstash the original
// into that new directory, rather than into the root of the biuld.
stage "second step on second node"
 
// Run on a node with the "second-node" label.
node('second-node') {
    // Run the unstash from within that directory!
    dir("first-stash") {
        unstash "first-stash"
    }
 
    // Look, no output directory under the root!
    // pwd() outputs the current directory Pipeline is running in.
    sh "ls -la ${pwd()}"
 
    // And look, output directory is there under first-stash!
    sh "ls -la ${pwd()}/first-stash"
}
   
```

[This says](http://getmesh.io/Blog/Jenkins+2+Pipeline+101) the name of the node is `node('!master')`, any node except the master is selected.

### Remote Loader Plugin

[This video](https://www.youtube.com/watch?v=emV60CcDVV0&t=46m01s) introduces this feature.

A pipline Groovy file can be loaded from any repo within a pipeline, like what “include” statements do.

[This](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/load-from-file/pipeline.groovy) shows how to “include” a file instead of duplicating code.

```groovy
node {
    // Load file from the current directory:
    def externalMethod = load("externalMethod.groovy")
    externalMethod.lookAtThis("Steve")

    def externalCall = load("externalCall.groovy")
    externalCall("Steve")
}
   
```

The [externalMethod.groovy](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/load-from-file/externalMethod.groovy) file contains:

```groovy
def myVar = build.getEnvironment(listener).get('myVar')

// Methods in this file will end up as object methods on the object that load returns.
def lookAtThis(String whoAreYou) {
   echo "Look at this, ${whoAreYou}! You loaded this from another file!"
}
   
```

The [externalCall.groovy](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/load-from-file/externalCall.groovy) file contains:

```groovy
def call(String whoAreYou) {
    echo "Now we're being called more magically, ${whoAreYou}, thanks to the call(...) method."
}
   
```

[This](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/load-from-file/loadFromGithub.groovy) shows how to “include” a file instead of duplicating code.

```groovy
#!groovy
 
apply from: 'https://raw.githubusercontent.com/org-name/repo-name/master/subfolder/Jenkinsfile?token=${env.GITHUB_TOKEN}'
   
```

In this example, the “org-name”, “repo-name” are replaced with actuals.

The “GITHUB_TOKEN” is a variable so its value is not exposed in code.

### GitHub Hooks #

Git Hooks are programs placed in a hooks directory to trigger actions at certain points in git’s execution. The list of hooks at:  
[https://www.kernel.org/pub/software/scm/git/docs/githooks.html](https://www.kernel.org/pub/software/scm/git/docs/githooks.html)  
include pre-commit, post-commit, etc.

Hooks that don’t have the executable bit set are ignored.

-   [http://www.chilipepperdesign.com/2013/01/07/deploying-code-with-git/](http://www.chilipepperdesign.com/2013/01/07/deploying-code-with-git/)

___

## Item: Organization Folders

Organization folders enable Jenkins to automatically detect and include as resources any new repository under an account/organization.

### Run Maven #

Alternately, if you want to run a Maven file:

```groovy
node ('linux'){
   stage 'Build and Test'
   env.PATH = "${tool 'Maven 3'}/bin:${env.PATH}"
  checkout scm
  sh 'mvn clean package'
}
   
```

CAUTION: Watch for “Error while checking in file to scm repository”.

### Parallel jobs

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/jobs-in-parallel/jobs_in_parallel.groovy) is an example of how to run several jobs in parallel. Define array “branches” for execution by in a “parallel” command which executes all items in the array at the same time.

```groovy
def branches = [:]
 
for (int i = 0; i < 4; i++) {
  def index = i //if we tried to use i below, it would equal 4 in each job execution.
  branches["branch${i}"] = {
    build job: 'test_jobs', parameters: [[$class: 'StringParameterValue', name: 'param1', value:
      'test_param'], [$class: 'StringParameterValue', name:'dummy', value: "${index}"]]
    }
}
parallel branches
   
```

The for loop interrates 4 times through the array (0, 1, 2, 3), each containing a “build job” command.

param1 : an example string parameter for the triggered job.

dummy: a parameter used to prevent triggering the job with the same parameters value. This parameter has to accept a different value each time the job is triggered. WQ//we have to assign it outside the closure or it will run the job multiple times with the same parameter “4” //and jenkins will unite them into a single run of the job

Remember it’s not permitted to have a stage step inside a parallel block.

### Cause

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/get-build-cause/getBuildCause.groovy) is a definition pulling in [cause](http://javadoc.jenkins-ci.org/hudson/model/class-use/Cause.html) info available to Freestyle build jobs as a $CAUSE variable

```groovy
// Get all Causes for the current build
def causes = currentBuild.rawBuild.getCauses()
 
// Get a specific Cause type (in this case the user who kicked off the build):
def specificCause = currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause)
   
```

[Here](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/parallel-from-grep/parallelFromGrep.groovy) is an alternative.

## Multi-branch projects

Instead of Jenkins types Freestyle and Pipeline, select **Multi-branch**.

-   [https://jenkins.io/blog/2015/12/03/pipeline-as-code-with-multibranch-workflows-in-jenkins/](https://jenkins.io/blog/2015/12/03/pipeline-as-code-with-multibranch-workflows-in-jenkins/)
    
-   [https://www.youtube.com/watch?v\=emV60CcDVV0&t\=1h20m20s](https://www.youtube.com/watch?v=emV60CcDVV0&t=1h20m20s)
    

[In this video](https://www.youtube.com/watch?v=emV60CcDVV0&t=59m57s) Jesse

## Durable Task Plugin

For long-running build runs at  
[https://wiki.jenkins-ci.org/display/JENKINS/Durable+Task+Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Durable+Task+Plugin)

“Library offering an extension point for processes which can run outside of Jenkins yet be monitored.”

### Safe Restart Plugin

Some install the [SafeRestart plug-in](https://wiki.jenkins-ci.org/display/JENKINS/SafeRestart+Plugin) which adds the **Restart Safely** option to the [Jenkins left menu](https://cloud.githubusercontent.com/assets/300046/12584913/9681b1d2-c3fe-11e5-9359-e51fc5809734.png "jenkins saferestart_plugin") to avoid needing to be at the server console at all.

To restart Jenkins server:

1.  PROTIP: Restart Jenkins by changing the URL from:
    
    ```
    http://.../pluginManager/installed
    
    ```
    
    to
    
    ```
    http://.../restart
    
    ```
    
2.  Click Yes to “Are you sure”.
    
3.  “Please wait while Jenkins is restarting”.
    
    ### Workspace Cleanup
    
    [Workspace](https://wiki.jenkins-ci.org/display/JENKINS/Workspace+Cleanup+Plugin)
    
    ### Discard Old Builds
    
    The [Jenkins.io](https://github.com/jenkins-infra/jenkins.io/blob/master/Jenkinsfile) Jenkinsfile Groovy script has this:
    
    ```groovy
    /* Only keep the 10 most recent builds. */
    properties([[$class: 'BuildDiscarderProperty',
                 strategy: [$class: 'LogRotator', numToKeepStr: '10']]])
    
    ```
    
    This is needed because build jobs can fill up a lot of disk space, especially if you store the build artifacts (binary files, such as JARs, WARs, TARs, etc.). So specify a limit on how many builds to store.
    
    There is a default ‘Discard Old Build’ function. But there is a plugin provides more choices to trigger deletion.
    
4.  In Manage Plugins, filter for “Discard Old Build” plugin at  
    [https://wiki.jenkins-ci.org/display/JENKINS/Discard+Old+Build+plugin](https://wiki.jenkins-ci.org/display/JENKINS/Discard+Old+Build+plugin)
    
    Alas, there are [bugs in it since Feb 2016](https://issues.jenkins-ci.org/browse/JENKINS-32858) which render it unusable. We didn’t find this bug until we wasted several hours trying to figure out what we did wrong.
    
5.  Specify the “Max # of builds to keep” (10).
6.  Check the “Status to keep” checkboxes (to the left of) “Unstable” and “Failure”.
    
7.  Click “Keep this job forever” on a specific build.

## Monitoring

1.  Install the “Jenkins Monitoring” plugin.
    
2.  From the Manage Jenkins screen, access the JavaMelody graphs in the “Monitoring of Jenkins/Jenkins master” or “Jenkins/Jenkins nodes” menu entries.
    
    It reports about the state of your build server, including CPU and system load, average response time, and memory usage. JavaMelody.
    

BTW, @jenx_monitor is a A Jenkins build server monitor for Mac OS X, powered by MacRuby. This app sits in your status bar and reports the status of all your Jenkins builds.

1.  Install the **Disk Usage** plugin to show a trend graph over time the disk space used by each project.

## Chaining in the Pipeline

Jenkins v1 consisted of many atomic jobs chained together by a mix of triggers and parameters.

![jenkins cd flow 650x261-i15.jpg](https://cloud.githubusercontent.com/assets/300046/17418538/45f540d2-5a56-11e6-8730-39528384e435.jpg)

### CI vs CD #

Continuous Integration (CI) **merges** development work in a developer’s branch with the team’s common code to ensure that changes still work in a testing environment. It’s call continuous to emphasize small changes being integrated frequently to stay in sync with an evolving team codebase. This requires individual changes to be scoped for completion in a short amount of time (hours at most).

Continuous Delivery (CD) delivers code for running in an UAT or Staging environment (of full production scale) used by end-users (QA or customers) to process business transactions in inspection mode. It’s called continuous for frequency to find more issues early, before each particular version has left the memory of developers.

Continuous Deployment moves code to Production. This is done by merging to the Mainline/Master branch which gets copied to the Production environment. It’s called continuous to make this happen as soon as code is ready.

BTW, [Assembla](https://blog.assembla.com/AssemblaBlog/tabid/12618/bid/92411/Continuous-Delivery-vs-Continuous-Deployment-vs-Continuous-Integration-Wait-huh.aspx) has more ideas about this.

### Slack notification REST API

[This](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/slacknotify/slackNotify.groovy) script imports Goovy’s built-in library to output Json using the “JsonOutput.toJson” class.method. The JSON output is the body (payload) of a REST API call to [Slack.com](http://slack.com/) made using the Linux curl command:

```groovy
import groovy.json.JsonOutput
def notifySlack(text, channel) {
    def slackURL = 'https://hooks.slack.com/services/xxxxxxx/yyyyyyyy/zzzzzzzzzz'
    def payload = JsonOutput.toJson([text      : text,
                                     channel   : channel,
                                     username  : "jenkins",
                                     icon_emoji: ":jenkins:"])
    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slackURL}"
}
   
```

// Add whichever params you think you’d most want to have // replace the slackURL below with the hook url provided by // slack when you configure the webhook

### IRC notification

[This](https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/ircnotify-commandline/ircNotify.groovy) snippet for just the “notify” stage shows how to invoke a Bash shell command (“sh”) to use the “nc” (netcat) command (on the last line below).

```groovy
stage "notify"
 
node {    
    sh ''' 
        MSG='This is the message here'
        SERVER=irc.freenode.net
        CHANNEL=#mictest
        USER=mic2234test
        (
        echo NICK $USER
        echo USER $USER 8 * : $USER
        sleep 1
        #echo PASS $USER:$MYPASSWORD                                                                                                                                           
        echo "JOIN $CHANNEL"
        echo "PRIVMSG $CHANNEL" :$MSG
        echo QUIT
        ) | nc $SERVER 6667
    '''
}
   
```

The shell command above first defines environment variables, then between (parentheses) specifies the commands piped into the nc command.

The “nc” (netcat) command is built into most Linux servers (including Mac OSX). It’s used instead of Telnet here.

A [“raw” connection](http://phil.lavin.me.uk/tag/irc-with-netcat/) is established on default port 6667. Your enterprise network may not allow it.

You need to modify the “This is the message here” text to a variable updated internally in the script based on results of the previous stage.

Also modify values to variables CHANNEL and USER.

$MYPASSWORD comes from outside the script.

-   Command “NICK” sets the user nickname.
-   Command “PRIVMSG” sets the private message.  
    

BTW, [https://github.com/jenkins-infra/ircbot](https://github.com/jenkins-infra/ircbot)

## Code Static Scans

Typical rules include “Constant If Expression,” “Empty Else Block,” “GString As Map Key,” and “Grails Stateless Service.”

For Groovy code, CodeNarc (similar to PMD for Java) checks for potential defects, poor coding practices and styles, overly complex code, and so on.

SonarQube runs on its own server a set of Maven code quality related plugins against your Maven project, and stores results into its relational database

1.  Install Sonar on its own server.
2.  On Jenkins install the “Sonar” plugin.
3.  Configure access to the Sonar database via JDBC.
4.  Sonar has Maven and Ant bootstrap and Gradle bootstraps.
5.  Schedule Sonar build once a day for metrics.
    
    PROTIP: For metrics, schedule Sonar to run only once a day because Sonar stores metrics in 24-hour slices.
    

Code Complexity.

Test Coverage.

The “Violations” plugin generates reports and graphs from code quality run metrics generated for individual builds and trends over time. It’s configured in the “Build Settings” section.

## Build using Maven

pom.xml file.

## IntelliJ IDE Auto-complete

[.gdsl file for IntelliJ IDE code completion](https://www.youtube.com/watch?v=emV60CcDVV0&t=46m01s&t=40m50s) begins like this:

```groovy
//The global script scope
def ctx = context(scope: scriptScope())
contributor(ctx) {
method(name: 'build', type: 'Object', params: [job:'java.lang.String'], doc: 'Build a job')
   
```

### CPS Global Library

[This video](https://www.youtube.com/watch?v=emV60CcDVV0&t=44m52s) introduces [Continuation Passing Style](https://www.wikiwand.com/en/Continuation-passing_style) of “functional programming”, which means that, unlike the direct style people have been coding, CPS functions return a function rather than values.

The switch to “functional programming” is actually a natural progression many others are undergoing in 2016. The Jenkins development team has, over the years, adopted innovations in Java such as Spring, Guava, and Groovy, as evidenced by this from [slide 9 of the Intro presentation at ParisJUG 7 June 2016](https://speakerdeck.com/aheritier/introduction-to-jenkins-2-at-parisjug-2016) by Arnaud Heritier (@aheritier) of Cloudbees.

![jenkins java progression 650x207-i13.jpg](./img/a4d3329c-5ae4-11e6-9544-e20daaad9898.jpg)

## Parallel Runs

Running in parallel is especially useful for testing multi-platform apps.

```groovy
stage "test on supported OSes"
 
parallel (
  windows: { node {
    sh "echo building on windows now"
 }},
  mac: { node {
    sh "echo building on mac now"
}}
   
```

### Snippet generator

[http://…/pipeline-syntax/](https://wilsonmar.github.io/jenkins2-pipeline//http://…/pipeline-syntax/) has a snippet generator

-   [http://todobackend.com/](http://todobackend.com/)

## Videos on Jenkins2 Pipeline

If you prefer videos, these are specifically about Jenkins 2.0+

Several speakers spoke at the 2:42:35  
[Jenkins 2.0 Virtual Conf. May 2015](https://www.youtube.com/watch?v=fl5xfqtiNko/)

Jenkins creator Kohsuke Kawaguchi (Creator of Jenkins and CTO of Cloudbees) [YouTube channel](https://www.youtube.com/channel/UCT_pjuBAYn6Sm_u4YJt59Rw) :

-   [Jenkins 2.0 Virtual Conf. (take 2) 4 May 2015](https://www.youtube.com/watch?v=emV60CcDVV0/)
    
    -   Grow with you from simple to complex
    -   Text-based, in your VCS
    -   Handle lots of jobs without repetition
    -   Survive Jenkins restart
    -   Brings next level of reuse to Jenkins
-   [on 7 Oct 2015](https://www.youtube.com/watch?v=2eVyc_n8i1c/)
    

Pipeline author Jesse Glick ([@tyvole](https://twitter.com/tyvole/))

-   [Jenkins Workflow: security model & plugin compatibility Aug 2015](https://www.youtube.com/watch?v=_aLPahlSFHU)

Arnaud Heritier (@aheritier, aheitier) (Support Team Manager at Cloudbees)

-   [https://speakerdeck.com/aheritier/introduction-to-jenkins-2-at-parisjug-2016](https://speakerdeck.com/aheritier/introduction-to-jenkins-2-at-parisjug-2016) Slidedeck from Paris JUG June 2016 points to [Kohsuke’s 25 Sep 2015 proposal for Jenkins 2.0](https://groups.google.com/d/msg/jenkinsci-dev/vbXK7jjekFw/BievO0UxBgAJ).

[Robert “Bobby” Sandell](https://se.linkedin.com/in/robertsandell/) (<a target=”_blank” href=”[rsandell.com](https://www.rsandell.com/)), Software Engineer at Cloudbees Stockholm since June 2010 has these videos:

-   [Jenkins pipeline plugin demo](https://www.youtube.com/watch?v=_iFtmp72p_E)
    
-   [Jenkins 2.0. What? When? What is in it for me?](https://www.youtube.com/watch?v=M-rxJBdYIrw)
    

Jim Leitch

-   [Jenkins 2.0 What’s is new?](https://www.youtube.com/watch?v=th_0jGRTnJ4)

James Nord ([@JamesTeilo](https://twitter.com/JamesTeilo/))

-   [Jenkins 2.0 and Beyond (and Q&A)](https://www.youtube.com/watch?v=PsgQ4v4aBhA) 52:04

Tyler Croy, Jenkins Community Evangelist

-   [Interview by Matt Warner](https://dzone.com/articles/interview-with-r-tyler-crory-jenkins-community-eva) quotes: “With Jenkins 2 we’re starting to assert that Jenkins is the right place to define the entire software delivery pipeline from build to test, to packaging and deployment.”

## Texual info about Pipeline

-   [https://jenkins.io/doc/pipeline = Getting Started with Pipeline](https://jenkins.io/doc/pipeline/)
-   [https://jenkins.io/solutions/pipeline/](https://jenkins.io/solutions/pipeline/)
-   [https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin)
-   [https://github.com/jenkinsci/pipeline-plugin/blob/master/README.md#introduction](https://github.com/jenkinsci/pipeline-plugin/blob/master/README.md#introduction)
    
-   [https://gist.github.com/chinshr/aa87da01ec28335e3ffd](https://gist.github.com/chinshr/aa87da01ec28335e3ffd) Best of Jenkinsfile, a collection of useful workflow scripts ready to be copied into your Jenkinsfile on a per use basis. (from Juergen Fesslmeier)

Before “Pipeline” there was “Workflow”, these resources:

-   [https://dzone.com/storage/assets/413450-rc218-cdw-jenkins-workflow.pdf](https://dzone.com/storage/assets/413450-rc218-cdw-jenkins-workflow.pdf)
-   [http://www.tutorialspoint.com/jenkins/jenkins_configuration.htm](http://www.tutorialspoint.com/jenkins/jenkins_configuration.htm)
-   [http://www.mantidproject.org/Jenkins_Build_Servers](http://www.mantidproject.org/Jenkins_Build_Servers)

[https://github.com/jenkinsci/job-dsl-plugin/wiki/User-Power-Moves](https://github.com/jenkinsci/job-dsl-plugin/wiki/User-Power-Moves)

## Testing

1.  Install the “TAP Plugin”,  
    [http://testanything.org/](http://testanything.org/)
    
    This TAP test runner is supported by Mocha, tape, etc.
    

## Resources

-   [Jenkins.io/](https://jenkins.io/)
    
-   [Getting Started with Jenkins2](https://app.pluralsight.com/library/courses/jenkins-2-getting-started/exercise-files) 3h 36m video course published 28 Aug 2016 by [Wes Higbee](https://www.weshigbee.com/) ([@g0t4](https://www.twitter.com/@g0t4/)) is based on Jenkins 2.7.1.
    

## Latest Info about Jenkins

Follow [@jenkins_release](https://twitter.com/jenkins_release/) This bot tweets Jenkins plugin releases.

Tweet to [@jenkinsci](https://twitter.com/jenkinsci/) about [#Jenkins2](https://twitter.com/#jenkins2/)

CloudBees Verified account @CloudBees

[@jenkinsconf](https://twitter.com/jenkinsconf/) is the handle for Jenkins World, Sep 13-15 in Santa Clara, CA

@changelog podcast every Friday

## More on DevOps

This is one of a series on DevOps:

1.  [DevOps_2.0](https://wilsonmar.github.io/devops_2.0/)
2.  [ci-cd (Continuous Integration and Continuous Delivery)](https://wilsonmar.github.io/ci-cd/)
3.  [User Stories for DevOps](https://wilsonmar.github.io/user-stories-for-devops/)
4.  [Enterprise Software)](https://wilsonmar.github.io/enterprise-software/)
    
5.  [Git and GitHub vs File Archival](https://wilsonmar.github.io/git-and-github-vs-file-archival/)
6.  [Git Commands and Statuses](https://wilsonmar.github.io/git-commands-and-statuses/)
7.  [Git Commit, Tag, Push](https://wilsonmar.github.io/git-commits/)
8.  [Git Utilities](https://wilsonmar.github.io/git-utilities/)
9.  [Data Security GitHub](https://wilsonmar.github.io/data-security-github/)
10.  [GitHub API](https://wilsonmar.github.io/github-api/)
11.  [TFS vs. GitHub](https://wilsonmar.github.io/tfs-vs-github/)
    
12.  [Choices for DevOps Technologies](https://wilsonmar.github.io/devops-choices/)
13.  [Pulumi Infrastructure as Code (IaC)](https://wilsonmar.github.io/pulumi/)
14.  [Java DevOps Workflow](https://wilsonmar.github.io/java-devops-workflow/)
15.  [Okta for SSO & MFA](https://wilsonmar.github.io/okta/)
    
16.  [AWS DevOps (CodeCommit, CodePipeline, CodeDeploy)](https://wilsonmar.github.io/aws-devops/)
17.  [AWS server deployment options](https://wilsonmar.github.io/aws-server-deploy-options/)
18.  [AWS Load Balancers](https://wilsonmar.github.io/loadbal/)
    
19.  [Cloud services comparisons (across vendors)](https://wilsonmar.github.io/cloud-services-comparisons/)
20.  [Cloud regions (across vendors)](https://wilsonmar.github.io/cloud-regions/)
21.  [AWS Virtual Private Cloud](https://wilsonmar.github.io/aws-vpc/)
    
22.  [Azure Cloud Onramp (Subscriptions, Portal GUI, CLI)](https://wilsonmar.github.io/azure-cloud-onramp/)
23.  [Azure Certifications](https://wilsonmar.github.io/azure-certifications/)
24.  [Azure Cloud](https://wilsonmar.github.io/azure-cloud/)
    
25.  [Azure Cloud Powershell](https://wilsonmar.github.io/azure-cloud-powershell/)
26.  [Bash Windows using Microsoft’s WSL (Windows Subsystem for Linux)](https://wilsonmar.github.io/bash-windows/)
27.  [Azure KSQL (Kusto Query Language) for Azure Monitor, etc.](https://wilsonmar.github.io/kql/)
    
28.  [Azure Networking](https://wilsonmar.github.io/azure-networking/)
29.  [Azure Storage](https://wilsonmar.github.io/azure-storage/)
30.  [Azure Compute](https://wilsonmar.github.io/azure-compute/)
31.  [Azure Monitoring](https://wilsonmar.github.io/azure-monitoring/)
    
32.  [Digital Ocean](https://wilsonmar.github.io/digital-ocean/)
33.  [Cloud Foundry](https://wilsonmar.github.io/cloud-foundry/)
    
34.  [Packer](https://wilsonmar.github.io/packer/) automation to build Vagrant images
35.  [Terraform](https://wilsonmar.github.io/terraform/) multi-cloud provisioning automation
36.  [Hashicorp Vault and Consul](https://wilsonmar.github.io/hashicorp-vault/) to generate and hold secrets
    
37.  [Powershell Ecosystem](https://wilsonmar.github.io/powershell-ecosystem/)
38.  [Powershell on MacOS](https://wilsonmar.github.io/powershell-on-mac/)
39.  [Powershell Desired System Configuration](https://wilsonmar.github.io/powershell-dsc/)
    
40.  [Jenkins Server Setup](https://wilsonmar.github.io/jenkins-setup/)
41.  [Jenkins Plug-ins](https://wilsonmar.github.io/jenkins-plugins/)
42.  [Jenkins Freestyle jobs](https://wilsonmar.github.io/jenkins-freestyle/)
43.  [Jenkins2 Pipeline jobs using Groovy code in Jenkinsfile](https://wilsonmar.github.io/jenkins2-pipeline/)
    
44.  [Docker (Glossary, Ecosystem, Certification)](https://wilsonmar.github.io/docker/)
45.  [Make Makefile for Docker](https://wilsonmar.github.io/make-makefile/)
46.  [Docker Setup and run Bash shell script](https://wilsonmar.github.io/bash-scripts/)
47.  [Bash coding](https://wilsonmar.github.io/bash-coding/)
48.  [Docker Setup](https://wilsonmar.github.io/docker-setup/)
49.  [Dockerize apps](https://wilsonmar.github.io/dockerize/)
50.  [Docker Registry](https://wilsonmar.github.io/docker-registry/)
    
51.  [Maven on MacOSX](https://wilsonmar.github.io/maven-on-macos/)
    
52.  [Ansible](https://wilsonmar.github.io/ansible/)
53.  [Kubernetes Operators](https://wilsonmar.github.io/k8s-operators/)
54.  [OPA (Open Policy Agent) in Rego language](https://wilsonmar.github.io/opa-rego/)
    
55.  [MySQL Setup](https://wilsonmar.github.io/mysel-setup/)
    
56.  [Threat Modeling](https://wilsonmar.github.io/threat-modeling/)
57.  [SonarQube & SonarSource static code scan](https://wilsonmar.github.io/sonarqube/)
    
58.  [API Management Microsoft](https://wilsonmar.github.io/api-management-microsoft/)
59.  [API Management Amazon](https://wilsonmar.github.io/api-management-amazon/)
    
60.  [Scenarios for load](https://wilsonmar.github.io/scenarios-for-load/)
61.  [Chaos Engineering](https://wilsonmar.github.io/chaos-engineering/)

___

## Reference

- https://wilsonmar.github.io/jenkins2-pipeline/
- 