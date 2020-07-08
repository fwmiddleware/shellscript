#!/bin/bash
HOST=(ws301oag ws302oag)
FILE_NAME=/etc/sysconfig/iptables
FILE_STAT=/tmp/stat.log
PIDFILE=/tmp/checkiptables.pid
if [ -f $PIDFILE ]
then
	PID=$(cat $PIDFILE)
	ps -p $PID > /dev/null 2>&1
    if [ $? -eq 0 ]
	then
		echo "Process already running"
		exit 1
	else
    ## Process not found assume not running
		echo $$ > $PIDFILE
		if [ $? -ne 0 ]
		then
			echo "Could not create PID file"
			exit 1
		fi
	fi
else
	echo $$ > $PIDFILE
	if [ $? -ne 0 ]
	then
		echo "Could not create PID file"
		exit 1
	fi
fi

if [ -f $FILE_STAT ]
then
        rm -f $FILE_STAT
fi
for OAG in $(echo ${HOST[@]})
do
        printf "$OAG " >> $FILE_STAT && ssh $OAG "stat --printf '%Y\n' $FILE_NAME" 2>/dev/null >> $FILE_STAT
done
while [ -f $FILE_STAT ]
do
        for OAG in $(echo ${HOST[@]})
        do
                RUNTIME_STAT=$(ssh $OAG stat --printf '%Y' $FILE_NAME 2>/dev/null)
                ORIG_STAT=$(cat /tmp/stat.log | grep $OAG | awk '{print $2}')
                if [ $RUNTIME_STAT -ne $ORIG_STAT ]
                then
                        echo "WARNING.. FILE IS CHANGED!!!"
                        echo "iptables ALERT MAIL" | mail -s "ALERT.. File $FILE_NAME is CHANGED on HOST $OAG" giorgio.tarozzi@consulenti.fastweb.it
                        exit 0
                fi
        done
done

