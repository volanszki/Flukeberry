#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
settdir="$basedir/settings"

act_sleeptime=$(cat $settdir/sleeptime | awk -F "." '{print $2}')

if [ $act_sleeptime -gt "1" ] && [ "$1" == "-" ]; then
    new_sleeptime=$(echo $act_sleeptime - 1 | bc)
elif [ $act_sleeptime -lt "9" ] && [ "$1" == "+" ]; then
    new_sleeptime=$(echo $act_sleeptime + 1 | bc)
else
    new_sleeptime="$act_sleeptime"
fi

echo -n "0."$new_sleeptime > $settdir/sleeptime
