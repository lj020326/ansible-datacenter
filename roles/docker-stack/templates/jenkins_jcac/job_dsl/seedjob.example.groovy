//
// ref: https://github.com/jenkinsci/job-dsl-plugin/wiki/Tutorial---Using-the-Jenkins-Job-DSL
//

def seedJob='''
job('DSL-Tutorial-1-Test') {
    scm {
        git('git://github.com/quidryan/aws-sdk-test.git')
    }
    triggers {
        scm('H/15 * * * *')
    }
    steps {
        maven('-e clean test')
    }
}
'''

job("seedjob-test") {
    description()
    keepDependencies(false)
    disabled(false)
    concurrentBuild(false)
    steps {
        dsl {
            text(seedJob)
            ignoreExisting(false)
            removeAction("IGNORE")
            removeViewAction("IGNORE")
            lookupStrategy("JENKINS_ROOT")
        }
    }
}
