#!/usr/bin/env groovy

// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
// ref: https://devops.stackexchange.com/questions/11833/how-do-i-load-a-jenkins-shared-library-in-a-jenkins-job-dsl-seed
// ref: https://stackoverflow.com/questions/69364938/error-creating-jobdsl-parameters-programatically
String jobsRepoUrl = "https://gitea.admin.dettonville.int/infra/pipeline-automation-lib.git"
String seedJobName = "ADMIN/bootstrap-projects"

def createSeedJob(String seedJobName, String jobsRepoUrl) {
    String gitCredentialsId = 'dcapi-jenkins-git-user'

    folder("ADMIN") {
        properties {
            authorizationMatrix {
                inheritanceStrategy {
                    nonInheriting()
                }
                permissions([
                    "GROUP:Job/Build:admin",
                    "GROUP:Job/Cancel:admin",
                    "GROUP:Job/Configure:admin",
                    "GROUP:Job/Create:admin",
                    "GROUP:Job/Delete:admin",
                    "GROUP:Job/Discover:admin",
                    "GROUP:Job/Move:admin",
                    "GROUP:Job/Read:admin",
                    "GROUP:Job/Workspace:admin",
                ])
            }
        }
    }

    job(seedJobName) {
        description()
        keepDependencies(false)
        disabled(false)
        concurrentBuild(false)
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

// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
def buildSeedJobs(String seedJobName, String jobsRepoUrl) {
    createSeedJob(seedJobName, jobsRepoUrl)
}

buildSeedJobs(seedJobName, jobsRepoUrl)