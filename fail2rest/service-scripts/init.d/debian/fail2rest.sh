#! /bin/sh
### BEGIN INIT INFO
#
# Provides:             fail2rest
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Should-Start:         fail2ban
# Should-Stop:          fail2ban
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    fail2rest initscript
# Description:          fail2rest is a small REST server that aims allow full administration of a fail2ban server via HTTP
#
### END INIT INFO

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="fail2rest is a small REST server that aims to allow full administration of a fail2ban server via HTTP"
NAME=fail2rest                                 #CHANGE TO THE NAME OF YOUR FAIL2REST BINARY
DAEMON_DIR=/usr/bin                  	       #CHANGE TO YOUR FAIL2REST BINARY DIRECTORY
DAEMON="$DAEMON_DIR/$NAME"
DAEMON_ARGS="--config=/etc/fail2rest.json"  #CHANGE TO THE NAME OF YOUR FAIL2REST CONFIG FILE NAME AND DIRECTORY IF NEED BE
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start ()
{
    # Return
    # 0 if daemon has been started
    # 1 if daemon was already running
    # 2 if daemon could not be started
    log_daemon_msg "Starting system $NAME daemon"
    start-stop-daemon --start --background --pidfile $PIDFILE --make-pidfile --chdir $DAEMON_DIR --exec $DAEMON -- $DAEMON_ARGS
    log_end_msg $?

    # Add code here, if necessary, that waits for the process to be ready
    # to handle requests from services started subsequently which depend
    # on this one.  As a last resort, sleep for some time.
}


#
# Function that stops the daemon/service
#
do_stop()
{
        # Return
        #   0 if daemon has been stopped
        #   1 if daemon was already stopped
        #   2 if daemon could not be stopped
        #   other if a failure occurred
        log_daemon_msg "Stopping system $NAME daemon"
        start-stop-daemon --stop --retry=10 --pidfile $PIDFILE
        log_end_msg $?
}

case "$1" in
  start|stop)
        do_${1}
        ;;
  restart|reload|force-reload)
        do_stop
        do_start
        ;;
  status)
        status_of_proc "$NAME" "$DAEMON" && exit 0 || exit $?
        ;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|status|restart|reload|force-reload}" >&2
        exit 3
        ;;
esac

: