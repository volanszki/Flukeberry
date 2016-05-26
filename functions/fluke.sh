#!/bin/bash

export XAUTHORITY=/home/pi/.Xauthority
export DISPLAY=:0.0

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
lastdir="$basedir/last"
tempdir="$basedir/tmp"
imagdir="$basedir/images"
settdir="$basedir/settings"

datetime=$(date '+%Y/%m/%d - %H:%M(%S)')
datefile=$(echo $datetime | sed 's/ - /__/g' | tr '/' '-' | tr ':,(' '-' | sed 's/)//g') 
ethernet0=$(cat $settdir/ethernet0)
ethernet0_exist="0"
linked=$(ethtool $ethernet0 | grep "Link detected" | awk '{print $3}')
timeout=$(cat $settdir/timeout)
killed="0"
autochecker="0"

function ethernet0_restart	{
    sudo ifconfig $ethernet0 down
    sudo ifconfig $ethernet0 up
}

function cleaning	{
    rm $lastdir/*
    rm $tempdir/*
}

function watch_tcpdump() {
    echo "0" > $tempdir/killed
    sleep $timeout
    local is_it_still_running=$(ps aux | grep tcpdump | grep -v grep | wc -l)
    if [ "$is_it_still_running" != "0" ]; then
	sudo killall tcpdump
	echo "1" > $tempdir/killed
    fi
}

function check_ethernet0	{
    ls -l /sys/class/net | awk '{print $9}' | grep -v lo | grep . > $tempdir/int.list
    ethernet0_exist=$(grep $ethernet0 $tempdir/int.list | wc -l)
} 

function check_autochecker	{
    local scriptname="L2_discovery.service"
    autochecker=$(ps aux | grep "$scriptname" | grep -v grep | wc -l)
}

cleaning
check_ethernet0

if [ "$linked" == "no" ]; then
    $funcdir/result_not_connected.sh
else
    ethernet0_restart
    watch_tcpdump &
    sudo tcpdump -i $ethernet0 -v -s 1500 -c 1 '(ether[12:2]=0x88cc or ether[20:2]=0x2000)' >> $tempdir/tcpdump.out
    killed=$(cat $tempdir/killed)

    if [ "$killed" == "0" ] && [ "$ethernet0_exist" == "1" ]; then
	$funcdir/process_tcpdump.sh "$datetime"
    elif [ "$ethernet0_exist" == "0" ]; then
	$funcdir/result_int_not_exist.sh
    else
	$funcdir/result_not_recognized.sh
    fi
fi

wkhtmltoimage --crop-w 400 --quality 100 $lastdir/result.html $lastdir/result.jpg
echo $datefile > $lastdir/result.time
echo -n "" > $basedir/keyboard/patch.port

check_autochecker

if [ "$autochecker" != "0" ]; then
    display $lastdir/result.jpg &
fi
