#!/bin/sh
### BEGIN INIT INFO
# Provides:          lvm2 lvm
# Required-Start:    mountdevsubfs
# Required-Stop:
# Should-Start:      udev mdadm-raid cryptdisks-early multipath-tools-boot
# Should-Stop:       umountroot mdadm-raid
# X-Start-Before:    checkfs mountall
# X-Stop-After:      umountfs
# Default-Start:     S
# Default-Stop:
### END INIT INFO

SCRIPTNAME=/etc/init.d/lvm2

. /lib/lsb/init-functions

[ -x /sbin/vgchange ] || exit 0

case "$1" in
  start)
	log_action_begin_msg "Setting up LVM Volume Groups"
	/sbin/lvm vgchange -aay --sysinit >/dev/null
	log_action_end_msg "$?"
	;;
  stop|restart|force-reload|status)
	;;
  *)
	echo "Usage: $SCRIPTNAME start" >&2
	exit 3
	;;
esac
