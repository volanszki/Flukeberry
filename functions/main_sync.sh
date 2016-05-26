#!/bin/bash

basedir="$(cat ../settings/basedir)"
settdir="$basedir/settings"
measdir="$basedir/measurements"

syncserver="$(cat $settdir/syncserver)"
syncdir="$(cat $settdir/syncdir)"
syncuser="$(cat $settdir/syncauth | awk -F ";" '{print $1}')"
syncpass="$(cat $settdir/syncauth | awk -F ";" '{print $2}')"
synchost=$(echo $syncserver | cut -c 3- | awk -F "/" '{print $1}')
echo $synchost

echo -n ">>> Checking connectivity to "$synchost"................."
sudo mount -t cifs -o user=$syncuser,pass=$syncpass,uid=1000,gid=1000,iocharset=utf8 $syncserver $syncdir

ping -c 1 $synchost > /dev/null 2>&1
hostalive=$(echo $?)

if [ "$hostalive" == "0" ]; then
    echo "[ONLINE]"
    rsync -u --progress -v $measdir/* $syncdir/
    echo -e "\n>>> SUCCESSFULLY UPDATED!"
else
    echo -e "Can not connect to the remote host\nPlease check your network connectivity!"
fi

