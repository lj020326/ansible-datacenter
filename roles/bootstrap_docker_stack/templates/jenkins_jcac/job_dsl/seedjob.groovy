#!/usr/bin/env groovy

// ref: https://blog.ippon.tech/setting-up-a-shared-library-and-seed-job-in-jenkins-part-2/
// ref: https://devops.stackexchange.com/questions/11833/how-do-i-load-a-jenkins-shared-library-in-a-jenkins-job-dsl-seed
// ref: https://stackoverflow.com/questions/69364938/error-creating-jobdsl-parameters-programatically
String jobsRepoUrl = "{{ __docker_stack__jenkins_jcac__pipeline_lib_repo }}"
String gitCredentialsId = "{{ __docker_stack__jenkins_jcac__pipeline_lib_credential_id }}"

String seedJobName = "ADMIN/bootstrap-projects"

def createSeedJob(String seedJobName, String jobsRepoUrl, String gitCredentialsId) {
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
                    group { name('admin'); permissions(['Job/Read','Job/Configure','Job/Build']) }
                    group { name('Domain Admins'); permissions(['Job/Read','Job/Configure','Job/Build']) }
                    group { name('authenticated'); permissions(['Job/Read']) }
                }
            }
        }
    }

    pipelineJob(seedJobName) {
        description('Seed job to create and update all other Jenkins jobs from Git.')
        keepDependencies(false)
        disabled(false)
        quietPeriod(0)
        logRotator { numToKeep(10) }
        triggers { cron("H/15 * * * *") }

        definition {
            cpsScm {
                lightweight(true)
                scm {
                    git {
                        remote {
                            url jobsRepoUrl
                            credentials gitCredentialsId
                        }
                        branch "*/main"
                    }
                }
                // Move scriptPath inside cpsScm
                scriptPath 'jobs/jobdsl/seed.groovy' // Your Jenkinsfile path for the seed job
            }
        }
    }
}

// Pass the list of jobs to the function
createSeedJob(seedJobName, jobsRepoUrl, gitCredentialsId)

// ref: https://github.com/jenkinsci/job-dsl-plugin/wiki/Job-DSL-Commands#queue
println "Add ${seedJobName} to the job queue"
queue(seedJobName)
