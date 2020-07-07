#!/bin/bash
if [ $UID -eq 0 ]
then
	echo "Lo script non può essere lanciato da ROOT" ; exit 1
fi
START=$PWD
# VARIABILI by FILE CSV
SLIST=$(cat server_list.csv | grep -v '^#')
ULIST=$(cat user_list.csv)

# Pulizia file comandi
if [ -f $START/usercommand ]
then
	rm -f $START/usercommand
	touch $START/usercommand
fi	

# CREAZIONE LISTA COMANDI
while IFS= read -r LINE
do
    USER=$(echo "$LINE" | awk '{print $1}')
    UI=$(echo  "$LINE"  | awk '{print $2}')
    GID=$(echo "$LINE"  | awk '{print $3}')
    COMM=$(echo "$LINE" | awk '{print $4" "$5" "$6" "$7}')
	echo "useradd -u $UI -c '$COMM' -d /home/$USER -s /bin/bash $USER
echo 'Fastweb123' | passwd --stdin $USER
#usermod -g $GID $USER 
mkdir -p /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
chmod 400 /home/$USER/.ssh/authorized_keys
chown -R $USER:$GID /home/$USER/.ssh
" >> $START/usercommand
done < user_list.csv

# ESECUZIONE LISTA COMANDI
chmod +x $START/usercommand

for SERVER in $SLIST
do
TESTGROUP=$(ssh -tq $SERVER "grep -q "$GID" /etc/group" | sed 's/\r|$//g')
cat > $START/$SERVER-pw.sh <<EOS
#!/bin/bash
ssh -t $SERVER "sudo su -" < $START/usercommand
EOS
if [ -z "$TESTGROUP" ]
then
	usermod -g $GID $USER 
fi
bash -xv $START/$SERVER-pw.sh 
done
exit 0