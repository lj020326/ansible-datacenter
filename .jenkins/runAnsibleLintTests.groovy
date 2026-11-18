#!/usr/bin/env groovy

Map config = [:]

// config.ansibleLintPaths = [
//     'inventory/',
//     'roles/',
//     'playbooks/',
//     '.'
// ]

runAnsibleLintPipeline(config)
