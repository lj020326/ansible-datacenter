// Jenkinsfile for the ADMIN/bootstrap-projects job

pipeline {
    agent { label 'controller' } // Use the 'controller' label as defined in your Job DSL

    stages {
        stage('Run Job DSL Scripts') {
            steps {
                script {
                    // This step will process all your Job DSL definition files
                    // from the 'jobs/jobdsl/templates' directory.
                    jobDsl(
                        targets: 'jobs/jobdsl/templates/**/*.groovy',
                        removedJobAction: 'DELETE',
                        additionalClasspath: "vars/" + "\r\n" + "src/")
                    echo "All Jenkins jobs created/updated by Job DSL."
                }
            }
        }

        stage('Trigger Initial Pipeline Runs for Parameter Initialization') {
            when {
                // Only run this stage if JOBS_TO_TRIGGER is not empty
                expression { params.JOBS_TO_TRIGGER != null && params.JOBS_TO_TRIGGER.trim() != '' }
            }
            steps {
                script {
                    List<String> jobs = params.JOBS_TO_TRIGGER.split(',').collect { it.trim() } // Split and trim whitespace

                    if (jobs.isEmpty()) {
                        echo "No jobs specified in JOBS_TO_TRIGGER. Skipping initial triggers."
                    } else {
                        echo "Triggering initial runs for: ${jobs}"
                        jobs.each { jobName ->
                            echo "Triggering: ${jobName}"
                            build job: jobName,
                                  parameters: [
                                      booleanParam('InitializeParamsOnly', true) // Pass the boolean parameter
                                  ]
                        }
                    }
                }
            }
        }
    }
}