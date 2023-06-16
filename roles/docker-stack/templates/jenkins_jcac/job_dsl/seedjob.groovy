#!/usr/bin/env groovy

// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
// ref: https://devops.stackexchange.com/questions/11833/how-do-i-load-a-jenkins-shared-library-in-a-jenkins-job-dsl-seed
// ref: https://stackoverflow.com/questions/69364938/error-creating-jobdsl-parameters-programatically
String jobsRepoUrl = "{{ __docker_stack__jenkins_jcac_pipeline_lib_repo }}"

String seedJobName = "ADMIN/bootstrap-projects"

def createSeedJob(String seedJobName, String jobsRepoUrl) {
    String gitCredentialsId = 'bitbucket-ssh-jenkins'
    String seedJobFolder = seedJobName.split("/")[0]
    println "seedJobFolder=${seedJobFolder}"
    folder(seedJobFolder) {
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
        label("controller")
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

// ref: https://stackoverflow.com/questions/51212832/start-jenkins-job-immediately-after-creation-by-seed-job-with-parameters
// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
createSeedJob(seedJobName, jobsRepoUrl)

// ref: https://github.com/jenkinsci/job-dsl-plugin/wiki/Job-DSL-Commands#queue
println "Add ${seedJobName} to the job queue"
// queue(seedJobName)
