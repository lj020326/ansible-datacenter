#!/bin/bash

#
# Jenkins Swarm Client
#
# chkconfig: 2345 89 11
# description: jenkins-swarm-client

source /etc/rc.d/init.d/functions

[[ -e "/etc/jenkins/swarm-client" ]] && source "/etc/jenkins/swarm-client"

####
#### The following options can be overridden in /etc/jenkins/swarm-client
####

# The user to run swarm-client as
USER=${USER:="jenkins"}

# The location that the pid file should be written to
PIDFILE=${PIDFILE:="/var/run/jenkins/swarm-client.pid"}

# The location that the lock file should be written to
LOCKFILE=${LOCKFILE:="/var/lock/subsys/jenkins-swarm-client"}

# The location that the log file should be written to
LOGFILE=${LOGFILE:="/var/log/jenkins/swarm-client.log"}

# The location of the swarm-client jar file
SWARM_AGENT_JAR=${SWARM_AGENT_JAR:="/var/lib/jenkins/swarm-client.jar"}

# The arguments to pass to the JVM.  Most useful for specifying heap sizes.
JVM_ARGS=${JVM_ARGS:=""}

# The master Jenkins server to connect to
MASTER=${MASTER:="jenkins"}

# The port that the master is running Jenkins on
MASTER_PORT=${MASTER_PORT:="80"}

# The protocol that the master is running Jenkins with
MASTER_PROTOCOL=${MASTER_PROTOCOL:="http"}

# The username to use when connecting to the master
SWARM_AGENT_USERNAME=${SWARM_AGENT_USERNAME:=""}

# The password to use when connecting to the master
SWARM_AGENT_PASSWORD=${SWARM_AGENT_PASSWORD:=""}

# The file in which to store the password to use when connecting to the master
SWARM_AGENT_PASSWORD_FILE=${SWARM_AGENT_PASSWORD_FILE:=""}

# The name of this swarm agent
SWARM_AGENT_NAME=${SWARM_AGENT_NAME:="$(hostname)"}

# The number of executors to run, by default one per core
SWARM_AGENT_NUM_EXECUTORS=${SWARM_AGENT_NUM_EXECUTORS:="$(/usr/bin/nproc)"}

# The labels to associate with each executor (space separated)
SWARM_AGENT_LABELS=${SWARM_AGENT_LABELS:=""}

ADDITIONAL_FLAGS=${SWARM_ADDITIONAL_FLAGS:="-disableClientsUniqueId"}

# The return value from invoking the script
RETVAL=0

start() {
  echo -n $"Starting Jenkins Swarm Client... "

  # create all the folders that will be needed
  PIDDIR=$(dirname "${PIDFILE}")
  echo $"Creating folder for PID: ${PIDDIR}"
  mkdir -p "${PIDDIR}"
  chown "${USER}":"${USER}" "${PIDDIR}"

  LOGDIR=$(dirname "${LOGFILE}")
  echo $"Creating folder for LOG: ${LOGDIR}"
  mkdir -p "${LOGDIR}"
  chown "${USER}":"${USER}" "${LOGDIR}"

  LOCKDIR=$(dirname "${LOCKFILE}")
  echo $"Creating folder for LOCK: ${LOCKDIR}"
  mkdir -p "${LOCKDIR}"
  chown "${USER}":"${USER}" "${LOCKDIR}"

  # give the user specified all permissions to the directory containing the jar file
  chown "${USER}":"${USER}" $(dirname "${SWARM_AGENT_JAR}")

  # Must be in /var/lib/jenkins for the swarm client to run properly
  local cmd="cd /var/lib/jenkins;"

  cmd="${cmd} java ${JVM_ARGS} "
  cmd="${cmd} -jar '${SWARM_AGENT_JAR}'"
  cmd="${cmd} -master '${MASTER_PROTOCOL}://${MASTER}:${MASTER_PORT}'"

  if [[ -n "${SWARM_AGENT_USERNAME}" ]]; then
    cmd="${cmd} -username '${SWARM_AGENT_USERNAME}'"
  fi

  if [[ -n "${SWARM_AGENT_PASSWORD_FILE}" ]]; then
    cmd="${cmd} -password '@${SWARM_AGENT_PASSWORD_FILE}'"
  elif [[ -n "${SWARM_AGENT_PASSWORD}" ]]; then
    cmd="${cmd} -password '${SWARM_AGENT_PASSWORD}'"
  fi

  cmd="${cmd} -name '${SWARM_AGENT_NAME}'"

  if [[ -n "${SWARM_AGENT_LABELS}" ]]; then
    cmd="${cmd} -labels '${SWARM_AGENT_LABELS}'"
  fi

  cmd="${cmd} -executors '${SWARM_AGENT_NUM_EXECUTORS}'"
  cmd="${cmd} ${ADDITIONAL_FLAGS}"
  cmd="${cmd} >> '${LOGFILE}' 2>&1 </dev/null &"

  daemon --user "${USER}" --check "swarm-client" --pidfile "${PIDFILE}" "${cmd}"

  local pid=$(sudo -u "${USER}" jps -l | grep "${SWARM_AGENT_JAR}" | awk '{print $1}')
  [ -n ${pid} ] && echo ${pid} > "${PIDFILE}"
  RETVAL=$?
  [ $RETVAL -eq 0 ] && touch $LOCKFILE

  echo
}

stop() {
  echo -n $"Stopping Jenkins Swarm Client... "
  killproc -p $PIDFILE "swarm-client"
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
}

restart() {
  stop
  start
}

checkstatus() {
  status -p "$PIDFILE" "swarm-client"
  RETVAL=$?
}

condrestart() {
  [ -e "$LOCKFILE" ] && restart || :
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    checkstatus
    ;;
  restart)
    restart
    ;;
  condrestart)
    condrestart
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart|condrestart}"
    exit 1
esac

exit $RETVAL
