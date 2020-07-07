#!/bin/bash
HOSTSFILE="/tmp/HOSTS"
tail -1 /tmp/USER > /tmp/USERNORMAL
USERFILE="/tmp/USERNORMAL"
HOMEPATH="/home/$UNAME"

for i in `cat $HOSTSFILE` ;
do
	USERID=`awk -F'\t' '{print $2}' $USERFILE`
	GROUPID=`awk -F'\t' '{print $3}' $USERFILE`
	if ! [[ "$USERID" =~ ^[0-9]+$ ]]
    then
        echo "UID is not a valid number" && exit 1
	fi
		if ! [[ "$GROUPID" =~ ^[0-9]+$ ]]
    then
        echo "GID is not a valid number" && exit 1
	fi
	CKUID=`ssh $i 'grep -c "^${USERID}:" /etc/passwd'`
	CKGID=`ssh $i 'grep -c "^${GROUPID}:" /etc/group'`
	if [[ -ne "$CKUID" ]] || [[ -ne "$CKGID" ]]
	then
		echo "USER ID is currently AVAILABLE on HOST $i, ready to add new user.." ; sleep 5
		echo "'useradd -u "$USERID" -d "$HOMEPATH" -s /bin/bash -c "$ROLE" -m -k /etc/skel/ "$UNAME"'"
		UNAME=`awk -F'\t' '{print $1}' $USERFILE`
		PASSWORD=`awk -F'\t' '{print $4}' $USERFILE`
		COMMENT=`awk -F'\t' '{print $5}' $USERFILE`     
		ssh $i 'useradd -u "$USERID" -d "$HOMEPATH" -s /bin/bash -c "$ROLE" -m -k /etc/skel/ "$UNAME"'
		ssh $i 'echo "$PASSWORD" | passwd --stdin "$UNAME"'
		ssh $i 'mkdir /home/"$UNAME"/.ssh ; chmod 700 /home/"$UNAME"/.ssh ; touch /home/"$UNAME"/.ssh/authorized_keys ; chmod 400 /home/"$UNAME"/.ssh/authorized_keys ; chown -R "$UNAME" /home/"$UNAME"/.ssh'
		### NEVER EXPIRE 
		ssh $i 'chage -m 0 -M 99999 -I -1 -E -1'
		### CHANGE PASSWORD 
		ssh $i 'chage -d 0 user'
	
	else
		echo "User ID or GID exist on $i, check new ID" && exit 1
	fi
done