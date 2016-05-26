#!/bin/bash

basedir="$(cat ../settings/basedir)"
tempdir="$basedir/tmp"

ls -l /sys/class/net | awk '{print $9}' | grep -v lo | grep . > $tempdir/int.list

while read line; do

mac=$(ifconfig $line | grep HWaddr | awk '{print $5}')
ip=$(ifconfig $line | grep "inet addr" | awk -F "addr:" '{print $2}' | awk '{print $1}')
mask=$(ifconfig $line | grep "inet addr" | awk -F "Mask:" '{print $2}' | awk '{print $1}')

if [ "$ip" == "" ]; then ip="N/A"; fi
if [ "$mask" == "" ]; then mask="N/A"; fi

echo "Interface name: "$line
echo "IP Address: "$ip
echo "Netmask: "$ip
echo "MAC Address: "$mac
echo ""

done < $tempdir/int.list
