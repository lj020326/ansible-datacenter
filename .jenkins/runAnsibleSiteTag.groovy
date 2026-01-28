#!/usr/bin/env groovy

import com.dettonville.pipeline.utils.JsonUtils

Map config=[:]

// config.environment = "${env.JOB_NAME.split('/')[-2]}"
// config.ansibleInventory = "./inventory/${config.environment}/hosts.yml"

// config.ansibleCollectionsRequirements = 'requirements.yml'
config.ansibleCollectionsRequirements = "collections/requirements.yml"

config.ansibleVault = "./vars/vault.yml"
config.ansiblePlaybook = "./site.yml"
config.ansibleVaultCredId = "ansible-vault-password-file"
config.ansibleVault = "./vars/vault.yml"

config.gitRepoUrl = "ssh://git@gitea.admin.dettonville.int:2222/infra/ansible-datacenter.git"
config.gitCredentialsId = 'gitea-ssh-jenkins'
config.gitRemoteBuildSummary = "ansible-datacenter"

runAnsibleParamWrapper(config)
