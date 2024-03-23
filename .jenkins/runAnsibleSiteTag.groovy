#!/usr/bin/env groovy

import com.dettonville.api.pipeline.utils.JsonUtils

Map config=[:]

config.gitBranch = 'main'
config.gitCredId = 'bitbucket-ssh-jenkins'

// config.environment = "${env.JOB_NAME.split('/')[-2]}"
// config.ansibleInventory = "./inventory/${config.environment}/hosts.yml"

// config.ansibleCollectionsRequirements = './collections/requirements.molecule.yml'
// config.ansibleRolesRequirements = './roles/requirements.molecule.yml'
config.ansibleCollectionsRequirements = './collections/requirements.yml'
// config.ansibleRolesRequirements = './roles/requirements.yml'
config.ansibleVault = "./vars/vault.yml"
config.ansiblePlaybook = "./site.yml"
config.ansibleVaultCredId = "ansible-vault-password-file"
// config.ansibleInstallation = "/root/.venv/ansible/bin/ansible"
// config.ansibleInstallation = "ansible-venv"
config.ansibleVault = "./vars/vault.yml"

runAnsibleParamWrapper(config)
