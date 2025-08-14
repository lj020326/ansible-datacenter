#!/usr/bin/env groovy

import com.dettonville.pipeline.utils.logging.Logger
import com.dettonville.pipeline.utils.JsonUtils

Logger log = new Logger(this)

Map config = [:]

config.ansibleInventoryBaseDir = "./inventory"
config.ansibleInventoryList = ['PROD', 'QA', 'DEV']

// log.info("config=${JsonUtils.printToJsonString(config)}")

runAnsibleInventoryTestJob(config)
