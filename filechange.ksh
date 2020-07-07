#!/bin/sh
#
# usage: filechange.ksh /etc/sysconfig/iptables your.name@domain.com
#

if [ $# -ne 2 ]
then
	echo "Usage: filechange.ksh /etc/sysconfig/iptables your.name@domain.com"
	exit 1
fi

#inotifywait is ALREADY RUNNING?
if [ $(ps aux | grep inotifywait | grep -c $1 ) -gt 0 ]
then
	echo “A process monitoring the file $1 is already running: $(ps aux | grep inotifywait | grep “$1” )”;
	exit 1;
fi

#inotifywait EXISTS
type -P inotifywait &>/dev/null 
if [ $? != 0 ]
then
	echo "Package inotifywait is not installed.. Do you want to install it now?" ; read RISP
	if [[ "$RISP" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
		if [ -x /bin/yum ]
		then
			/bin/yum -y install epel-release
			/bin/yum -y install inotify-tools
		else
			echo "This script runs only on RHEL like distibution..." ; exit 1
		fi	
	else
		echo "Exiting..." ; exit 1
	fi
fi	
	
# MAIN
if [ -f $1 ]
then
	echo “Monitoring file $1 for changes - sending alerts to $2”
	while inotifywait -e modify -e attrib -e move -e delete $1 -o /tmp/audit.log
	do
		sleep 1
		CHANGES="$(cat /tmp/audit.log)"
		echo "The following change occurred in the file $1 : $CHANGES" | mail -s "ALERT.. File $1 is changed!!!" $2
		rm /tmp/audit.log
		touch /tmp/audit.log		
	done
else
	echo “Error: File $1 not found”
	exit1
fi