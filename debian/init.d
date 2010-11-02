#! /bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/dns-cache-monitor
NAME=`basename ${DAEMON}`
DESC="DNS anycast cache monitor"
PID=/var/run/${NAME}.pid

test -x $DAEMON || exit 0

# Include dns-cache-monitor defaults if available
if [ -f /etc/default/dns-cache-monitor ] ; then
	. /etc/default/dns-cache-monitor
fi

. /lib/lsb/init-functions
DISTRO=$(lsb_release -is 2>/dev/null || echo Debian)

set -e

case "$1" in
  start)
	log_daemon_msg "Starting $DESC" $DAEMON
	if [ ! -x $DAEMON ]; then
	    log_action_msg "$DAEMON missing - not starting"
	    log_end_msg 1
	    exit 1
	fi
	## --name checks the command name in /proc/$pid/stat, but that
	## appears to be limited to 14 characters.  Also, we must use
	## --starts instead --exec to start a script, because the
	## latte would check /proc/$pid/exe, which points to the
	## executable of the interpreter (/usr/bin/perl in this case)
	## rather than the script itself.
	start-stop-daemon --start --name dns-cache-monit --startas $DAEMON \
	    --pidfile $PID --  --pid-file=$PID $DAEMON_OPTS $ADDRV4 $ADDRV6
	log_end_msg 0
	;;
  stop)
	log_action_msg "Stopping $DESC"
	start-stop-daemon --stop --quiet --oknodo --pidfile $PID
	;;
  resume)
	log_action_msg "Signalling cache monitor to wake up"
	start-stop-daemon --stop --quiet --pidfile $PID --signal USR1
	;;
  restart|force-reload)
        $0 stop
	sleep 1
	$0 start
	;;
  *)
	N=/etc/init.d/$NAME
	echo "Usage: $N {start|stop|resume|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0
