#!/usr/bin/env groovy
import com.dettonville.api.pipeline.utils.logging.LogLevel
import com.dettonville.api.pipeline.utils.logging.Logger

import com.dettonville.api.pipeline.utils.JsonUtils

Logger log = new Logger(this)

Map config = [:]

config.ansibleInventoryBaseDir = "./inventory"
config.ansibleInventoryList = ['PROD', 'QA', 'DEV']

log.info("config=${JsonUtils.printToJsonString(config)}")

runAnsibleInventoryTestJob(config)
