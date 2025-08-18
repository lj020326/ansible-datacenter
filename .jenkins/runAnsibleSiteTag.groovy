#!/usr/bin/env groovy

import com.dettonville.pipeline.utils.JsonUtils

Map config=[:]

// config.environment = "${env.JOB_NAME.split('/')[-2]}"
// config.ansibleInventory = "./inventory/${config.environment}/hosts.yml"

config.ansibleVault = "./vars/vault.yml"
config.ansiblePlaybook = "./site.yml"
config.ansibleVaultCredId = "ansible-vault-password-file"
config.ansibleVault = "./vars/vault.yml"

config.gitRepoUrl = "git@bitbucket.org:lj020326/ansible-datacenter.git"
config.gitCredentialsId = 'bitbucket-ssh-jenkins'
config.gitRemoteBuildSummary = "ansible-datacenter"

runAnsibleParamWrapper(config)
