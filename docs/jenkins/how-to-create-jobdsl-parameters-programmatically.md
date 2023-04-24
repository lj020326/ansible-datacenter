
# How to create jobdsl parameters programmatically

I am creating jobs for use with Terraform. There are several environments and the number is growing all the time. Rather than update both the pipeline file and the jobdsl file as the parameters change, I started working from the standpoint of scanning the repo for environment files and updating the pipeline and jobdsl file as needed.

My jobdsl script:

```
@Library('mylib') _

params = [
  "serviceName": "infrastructure-${repo}",
  "repoUrl": "${repoUrl}",
  "sshCredentials": 'git-readonly',
  "environment": "${env.Environment}",
  "configParams": getTFConfigs(
      repoUrl, 
      "env/${env.AccountName}/${env.AWSRegion}/${env.Environment}")
  ]
template = libraryResource('dslTemplates/infra.groovy')
jobDsl scriptText: helpers.renderTemplate(template, params)
```

shared library method: getTFConfigs

```
#!/usr/bin/env groovy

@NonCPS
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream

def call(String repoUrl, String filter=""){
  def gitProc = new ProcessBuilder(
    "git",
    "archive",
    "--format=zip",
    "--remote=${repoUrl}",
    "main").start()
  def zipIn = new ZipInputStream(gitProc.inputStream)
  def zipMembers = []
  while (true) {
    def ZipEntry entry = zipIn.getNextEntry()
    if (entry == null) break
    if ( (entry.getName()).contains(filter) ) {
      entryName = entry.getName()
      zipMembers.push("${entryName}")
    }
  }
  println zipMembers
  return zipMembers
}

```

dslTemplates/infra.groovy template

```
pipelineJob("${serviceName}") {
  description("Apply TF for ${serviceName} to all environment configurations")
  definition {
    parameters {
      <% configParams.each { %>
      booleanParam(name: "<%= "${it}" %>", defaultValue: true, description: "<%= "${it}" %>" )
      <% } %>
    }
    logRotator {
      numToKeep(20)
    }
    cpsScm {
      scm {
        git{
          remote{
            url("${repoUrl}")
            credentials("${sshCredentials}")
            branch('*/main')
          }
        }
      }
      scriptPath('infra.groovy')
    }
  }
}
```

Template result

```
...  
definition {
    parameters {

      booleanParam(name: env1.tfvars, defaultValue: true, description: env1.tfvars )

      booleanParam(name: env2.tfvars, defaultValue: true, description: env2.tfvars )

    }
...
```

When the seed job runs and executes the code, the parameters should be updated with a checkbox for each environment. However, the jobdsl fails with this:

```
ERROR: (script, line 6) No signature of method: javaposse.jobdsl.dsl.helpers.BuildParametersContext.booleanParam() is applicable for argument types: (java.util.LinkedHashMap) values: [[name:env1.tfvars, defaultValue:true, ...]]
Possible solutions: booleanParam(java.lang.String), booleanParam(java.lang.String, boolean), booleanParam(java.lang.String, boolean, java.lang.String)
Finished: FAILURE
```

I have tried to applying "toString()" at various steps and cannot seem to find any solution to this. I have tried to write the entire jobdsl script to a file and read it back in using "jobDsl targets: filename" and got the same result!

## Solution

It looks like you used [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/#parameters) for the parameters in DSL script. If you want to define a parameter in a DSL script do not use `name`, `defaultValue` and `description`. (See [Job DSL Plugin](https://jenkinsci.github.io/job-dsl-plugin/#path/pipelineJob-parameters-booleanParam)).

```groovy
booleanParam('BOOL_PARAM', true, 'This is a boolean param')
```

## Reference

* https://stackoverflow.com/questions/69364938/error-creating-jobdsl-parameters-programatically

