#!/usr/bin/env groovy

// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
// ref: https://devops.stackexchange.com/questions/11833/how-do-i-load-a-jenkins-shared-library-in-a-jenkins-job-dsl-seed
// ref: https://stackoverflow.com/questions/69364938/error-creating-jobdsl-parameters-programatically
String jobsRepoUrl = "ssh://git@gitea.admin.dettonville.int:2222/infra/pipeline-automation-lib.git"

String seedJobName = "ADMIN/bootstrap-projects"

def createSeedJob(String seedJobName, String jobsRepoUrl) {
    String gitCredentialsId = 'gitea-ssh-jenkins'
    String seedJobFolder = seedJobName.split("/")[0]
    println "seedJobFolder=${seedJobFolder}"
    folder(seedJobFolder) {
        properties {
            authorizationMatrix {
                inheritanceStrategy {
                    nonInheriting()
                }
                // ref: https://github.com/jenkinsci/matrix-auth-plugin/releases
                entries {
                  user {
                      name('admin')
                      permissions([
                        'Overall/Administer'
                      ])
                  }
                  group {
                      name('admin')
                      permissions([
                        'Overall/Administer'
                      ])
                  }
                  group {
                      name('Domain Admins')
                      permissions([
                        'Overall/Administer'
                      ])
                  }
                  group {
                      name('authenticated')
                      permissions([
                        'Overall/Read'
                      ])
                  }
                }

//                 permissions([
//                     "GROUP:Job/Build:admin",
//                     "GROUP:Job/Cancel:admin",
//                     "GROUP:Job/Configure:admin",
//                     "GROUP:Job/Create:admin",
//                     "GROUP:Job/Delete:admin",
//                     "GROUP:Job/Discover:admin",
//                     "GROUP:Job/Move:admin",
//                     "GROUP:Job/Read:admin",
//                     "GROUP:Job/Workspace:admin",
//                 ])
            }
        }
    }

    job(seedJobName) {
        description()
        label("controller")
        keepDependencies(false)
        disabled(false)
        concurrentBuild(false)
        quietPeriod(0)
        logRotator {
          numToKeep(10)
        }
        // ref: https://github.com/tomasbjerre/jenkins-configuration-as-code-sandbox/blob/master/jenkins-docker/jenkins.yaml
        triggers {
          cron("H/20 * * * *")
        }
        scm {
            git {
                remote {
                    url(jobsRepoUrl)
                    credentials(gitCredentialsId)
                }
                branch("*/main")
            }
        }
        steps {
            jobDsl {
                targets "jobs/jobdsl/templates/**/*.groovy"
                // ref: https://marcesher.com/2016/06/21/jenkins-as-code-registering-jobs-for-automatic-seed-job-creation/
                additionalClasspath "vars/" + "\r\n" + "src/"
            }
        }
    }
}

// ref: https://stackoverflow.com/questions/51212832/start-jenkins-job-immediately-after-creation-by-seed-job-with-parameters
// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
createSeedJob(seedJobName, jobsRepoUrl)

// ref: https://github.com/jenkinsci/job-dsl-plugin/wiki/Job-DSL-Commands#queue
println "Add ${seedJobName} to the job queue"
// queue(seedJobName)
