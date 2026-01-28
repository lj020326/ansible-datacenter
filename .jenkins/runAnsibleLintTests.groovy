#!/usr/bin/env groovy

Map config = [:]

config.ansibleLintArgs = "-v"
// config.ansibleLintPaths = [
//     'inventory/',
//     'roles/',
//     'playbooks/',
//     '.'
// ]

runAnsibleLint(config)
