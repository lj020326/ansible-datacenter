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
JAR=${JAR:="/var/lib/jenkins/swarm-client.jar"}

# The arguments to pass to the JVM.  Most useful for specifying heap sizes.
JVM_ARGS=${JVM_ARGS:=""}

# The master Jenkins server to connect to
MASTER=${MASTER:="jenkins"}

# The port that the master is running Jenkins on
MASTER_PORT=${MASTER_PORT:="80"}

# The protocol that the master is running Jenkins with
MASTER_PROTOCOL=${MASTER_PROTOCOL:="http"}

# The username to use when connecting to the master
USERNAME=${SWARM_USERNAME:=""}

# The password to use when connecting to the master
PASSWORD=${SWARM_PASSWORD:=""}

# The file in which to store the password to use when connecting to the master
PASSWORD_FILE=${SWARM_PASSWORD_FILE:=""}

# The name of this slave
NAME=${NAME:="$(hostname)"}

# The number of executors to run, by default one per core
NUM_EXECUTORS=${NUM_EXECUTORS:="$(/usr/bin/nproc)"}

# The labels to associate with each executor (space separated)
LABELS=${LABELS:=""}

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
  chown "${USER}":"${USER}" $(dirname "${JAR}")

  # Must be in /var/lib/jenkins for the swarm client to run properly
  local cmd="cd /var/lib/jenkins;"

  cmd="${cmd} java ${JVM_ARGS} "
  cmd="${cmd} -jar '${JAR}'"
  cmd="${cmd} -master '${MASTER_PROTOCOL}://${MASTER}:${MASTER_PORT}'"

  if [[ -n "${USERNAME}" ]]; then
    cmd="${cmd} -username '${USERNAME}'"
  fi

  if [[ -n "${PASSWORD_FILE}" ]]; then
    cmd="${cmd} -password '@${PASSWORD_FILE}'"
  elif [[ -n "${PASSWORD}" ]]; then
    cmd="${cmd} -password '${PASSWORD}'"
  fi

  cmd="${cmd} -name '${NAME}'"

  if [[ -n "${LABELS}" ]]; then
    cmd="${cmd} -labels '${LABELS}'"
  fi

  cmd="${cmd} -executors '${NUM_EXECUTORS}'"
  cmd="${cmd} ${ADDITIONAL_FLAGS}"
  cmd="${cmd} >> '${LOGFILE}' 2>&1 </dev/null &"

  daemon --user "${USER}" --check "swarm-client" --pidfile "${PIDFILE}" "${cmd}"

  local pid=$(sudo -u "${USER}" jps -l | grep "${JAR}" | awk '{print $1}')
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
