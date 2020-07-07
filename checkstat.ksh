#!/bin/bash
HOST='ws302oag'
FILE_NAME=/etc/sysconfig/iptables-copy
FILE_STAT=/tmp/stat.log

LF=/tmp/pidLockFile
cat /dev/null >> $LF	
read lastPID < $LF

[ ! -z "$lastPID" -a -d /proc/$lastPID ] && echo "Script $0 is already RUNNING" ; exit
echo Not RUNNING
echo $$ > $LF
sleep 1

ssh $HOST "stat --printf '%Y\n' $FILE_NAME" 2>/dev/null > $FILE_STAT
while [ -f $FILE_STAT ]
do
        RUNTIME_STAT=$(ssh $HOST stat --printf '%Y' $FILE_NAME 2>/dev/null)
        ORIG_STAT=$(cat /tmp/stat.log)
        if [ $RUNTIME_STAT -ne $ORIG_STAT ]
        then
                echo "WARNING.. FILE IS CHANGED!!!"
				echo "iptables ALERT MAIL" | mail -s "ALERT.. File $FILE_NAME is CHANGED" giorgio.tarozzi@consulenti.fastweb.it
                break
done
