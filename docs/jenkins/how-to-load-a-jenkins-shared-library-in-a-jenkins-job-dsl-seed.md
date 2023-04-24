
# How to load a Jenkins Shared Library in a Jenkins Job DSL seed

It's possible to use jobDSL from Pipeline. (E.g., using multibranch pipeline as it allows configuring pipelineTriggers).

You can configure your seed job to be a pipeline like this:

```groovy
def gitCredentialsId      = 'github-jenkins'
def jobsRepoName          = 'https://github.com/my-jobs-repo.git'
def sharedLibraryRepoName = 'https://github.com/shared-library-repo.git'

properties([    
   pipelineTriggers([githubPush()])
])

pipeline {
    agent any
    stages{
        stage('Seed Job') {
            agent any
            steps {

                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'shared-library']], 
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId:  gitCredentialsId, url: sharedLibraryRepoName ]]
                    ])

                git url: jobsRepoName, changelog: false, credentialsId: gitCredentialsId, poll: false, branch: 'main'
                jobDsl targets: 'jobs/**/*_job.groovy', additionalClasspath: 'shared-library/src'
            }
        }
    }
}
```

This way we can configure our seed job to checkout shared libraries repo into workspace subdirectory _shared-library_ and specify **additionalClasspath** for jobDSL groovy scripts

So in your groovy scripts you can simply use import without @Library annotation

## Reference

* https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-job-configuration-using-job-dsl
* https://devops.stackexchange.com/questions/11833/how-do-i-load-a-jenkins-shared-library-in-a-jenkins-job-dsl-seed#11862

