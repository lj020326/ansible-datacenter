#!/usr/bin/env groovy
import com.dettonville.api.pipeline.utils.logging.LogLevel
import com.dettonville.api.pipeline.utils.logging.Logger

import com.dettonville.api.pipeline.utils.JsonUtils

Logger.init(this, LogLevel.INFO)
Logger log = new Logger(this)
String logPrefix="runInventoryTests():"

Map config = [:]

config.ansibleInventoryBaseDir = "./inventory"
config.ansibleInventoryList = ['PROD', 'QA', 'DEV']

log.info("${logPrefix} config=${JsonUtils.printToJsonString(config)}")

runAnsibleInventoryTestJob(config)
