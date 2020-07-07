#!/bin/bash

createcsv.sh 
for i in $(cat $1 | grep -v '^#')
do
    echo "############"$i
    ssh psala@${i} "sudo su - " < create.csv 2>&1
done

FILE CSV :

useradd -u 3719 -g 2400 -c "# Utente CA Pam per BSS-Channel Management" pimchmgt
echo "Fastweb123" | passwd --stdin pimchmgt
mkdir /home/pimchmgt/.ssh
chmod 700 /home/pimchmgt/.ssh
touch /home/pimchmgt/.ssh/authorized_keys
chmod 400 /home/pimchmgt/.ssh/authorized_keys
chown -R pimchmgt:srvdry /home/pimchmgt/.ssh
chage -m 0 -M 99999 -I -1 -E -1 pimchmgt

./create_user.sh server_list_pimchmgt.csv


### NEVER EXPIRE + CHANGE PASSWORD 
chage -d 0 user
chage -E -1 -M -1 -d 0 username

