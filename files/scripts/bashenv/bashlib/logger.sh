#!/usr/bin/env bash

## ref: http://www.cubicrace.com/2016/03/log-tracing-mechnism-for-shell-scripts.html

#SCRIPT_LOG=~/SystemOut.log
SCRIPT_LOG=./SystemOut.log
touch $SCRIPT_LOG
logPrefix="msg"

LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

logLevel=${LOG_INFO}

logError() {
  if [ $logLevel -ge $LOG_ERROR ]; then
  	echo -e "[ERROR] ${logPrefix}: ${1}"
  fi
}
logWarn() {
  if [ $logLevel -ge $LOG_WARN ]; then
  	echo -e "[WARN] ${logPrefix}: ${1}"
  fi
}
logInfo() {
  if [ $logLevel -ge $LOG_INFO ]; then
  	echo -e "[INFO] ${logPrefix}: ${1}"
  fi
}
logTrace() {
  if [ $logLevel -ge $LOG_TRACE ]; then
  	echo -e "[TRACE] ${logPrefix}: ${1}"
  fi
}
logDebug() {
  if [ $logLevel -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG] ${logPrefix}: ${1}"
  fi
}


function SCRIPTENTRY(){
	timeAndDate=`date`
	script_name=`basename "$0"`
	script_name="${script_name%.*}"
#	echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $SCRIPT_LOG
	echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" | tee -a $SCRIPT_LOG
}

function SCRIPTEXIT(){
	script_name=`basename "$0"`
	script_name="${script_name%.*}"
#	echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $SCRIPT_LOG
	echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" | tee -a $SCRIPT_LOG
}

function ENTRY(){
	local cfn="${FUNCNAME[1]}"
	timeAndDate=`date`
#	echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $SCRIPT_LOG
	echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" | tee -a $SCRIPT_LOG
}

function EXIT(){
	local cfn="${FUNCNAME[1]}"
	timeAndDate=`date`
#	echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $SCRIPT_LOG
	echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" | tee -a $SCRIPT_LOG
}


function INFO(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
#    echo "[$timeAndDate] [INFO]  $msg" >> $SCRIPT_LOG
    echo "[$timeAndDate] [INFO]  $msg" | tee -a $SCRIPT_LOG
}


function DEBUG(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
#	echo "[$timeAndDate] [DEBUG]  $msg" >> $SCRIPT_LOG
    echo "[$timeAndDate] [DEBUG]  $msg" | tee -a $SCRIPT_LOG
}

function ERROR(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
#    echo "[$timeAndDate] [ERROR]  $msg" >> $SCRIPT_LOG
    echo "[$timeAndDate] [ERROR]  $msg" | tee -a $SCRIPT_LOG
}
