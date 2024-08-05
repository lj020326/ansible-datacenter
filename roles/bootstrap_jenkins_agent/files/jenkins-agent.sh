#!/bin/bash

#
# Jenkins Agent
#
# chkconfig: 2345 89 11
# description: jenkins-agent

source /etc/rc.d/init.d/functions

[[ -e "/etc/jenkins/jenkins-agent" ]] && source "/etc/jenkins/jenkins-agent"

####
#### The following options can be overridden in /etc/jenkins/jenkins-agent
####

# The user to run jenkins-agent as
USER=${USER:="jenkins"}

# The location that the pid file should be written to
PIDFILE=${PIDFILE:="/var/run/jenkins/jenkins-agent.pid"}

# The location that the lock file should be written to
LOCKFILE=${LOCKFILE:="/var/lock/subsys/jenkins-agent"}

# The location that the log file should be written to
LOGFILE=${LOGFILE:="/var/log/jenkins/jenkins-agent.log"}

# The location of the jenkins-agent jar file
JENKINS_AGENT_JAR=${JENKINS_AGENT_JAR:="/var/lib/jenkins/jenkins-agent.jar"}

# The arguments to pass to the JVM.  Most useful for specifying heap sizes.
JVM_ARGS=${JVM_ARGS:=""}

# The Jenkins controller to connect to
JENKINS_HOST=${JENKINS_HOST:="jenkins"}

# The port that the jenkins is running on
JENKINS_PORT=${JENKINS_PORT:="80"}

# The protocol that the jenkins is running
JENKINS_PROTOCOL=${JENKINS_PROTOCOL:="http"}

# The username to use when connecting to jenkins
JENKINS_AGENT_USERNAME=${JENKINS_AGENT_USERNAME:=""}

# The password to use when connecting to jenkins
JENKINS_AGENT_PASSWORD=${JENKINS_AGENT_PASSWORD:=""}

# The file in which to store the password to use when connecting to jenkins
JENKINS_AGENT_PASSWORD_FILE=${JENKINS_AGENT_PASSWORD_FILE:=""}

# The name of this swarm agent
JENKINS_AGENT_NAME=${JENKINS_AGENT_NAME:="$(hostname)"}

# The number of executors to run, by default one per core
JENKINS_AGENT_NUM_EXECUTORS=${JENKINS_AGENT_NUM_EXECUTORS:="$(/usr/bin/nproc)"}

#ADDITIONAL_FLAGS=${JENKINS_AGENT_ADDITIONAL_FLAGS:="-disableClientsUniqueId"}
ADDITIONAL_FLAGS=${JENKINS_AGENT_ADDITIONAL_FLAGS:=""}

# The return value from invoking the script
RETVAL=0

start() {
  echo -n $"Starting Jenkins Agent... "

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
  chown "${USER}":"${USER}" $(dirname "${JENKINS_AGENT_JAR}")

  # Must be in /var/lib/jenkins for the jenkins agent to run properly
  local cmd="cd /var/lib/jenkins;"

  cmd="${cmd} java ${JVM_ARGS} "
  cmd="${cmd} -jar '${JENKINS_AGENT_JAR}'"
  cmd="${cmd} -url '${JENKINS_PROTOCOL}://${JENKINS_HOME}:${JENKINS_PORT}'"

  if [[ -n "${JENKINS_AGENT_PASSWORD_FILE}" ]]; then
    cmd="${cmd} -password '@${JENKINS_AGENT_PASSWORD_FILE}'"
  elif [[ -n "${JENKINS_AGENT_PASSWORD}" ]]; then
    cmd="${cmd} -password '${JENKINS_AGENT_PASSWORD}'"
  fi

  cmd="${cmd} -name '${JENKINS_AGENT_NAME}'"

  cmd="${cmd} ${ADDITIONAL_FLAGS}"
  cmd="${cmd} >> '${LOGFILE}' 2>&1 </dev/null &"

  daemon --user "${USER}" --check "jenkins-agent" --pidfile "${PIDFILE}" "${cmd}"

  local pid=$(sudo -u "${USER}" jps -l | grep "${JENKINS_AGENT_JAR}" | awk '{print $1}')
  [ -n ${pid} ] && echo ${pid} > "${PIDFILE}"
  RETVAL=$?
  [ $RETVAL -eq 0 ] && touch $LOCKFILE

  echo
}

stop() {
  echo -n $"Stopping Jenkins Agent... "
  killproc -p $PIDFILE "jenkins-agent"
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
}

restart() {
  stop
  start
}

checkstatus() {
  status -p "$PIDFILE" "jenkins-agent"
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
