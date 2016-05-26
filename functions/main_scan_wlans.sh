#!/bin/bash

basedir="$(cat ../settings/basedir)"
tempdir="$basedir/tmp"
settdir="$basedir/settings"
wireless0=$(cat $settdir/wireless0)

function fix_ssid	{
    if [ "$ssid" == "" ]; then
	ssid="[unknown]"; 
        strlen=$(echo -n $ssid | wc -c)
    fi

    if [ $strlen -lt "7" ]; then
	local ssid_fixed="$(echo $ssid".....")"
	ssid="$ssid_fixed"
    fi

    if [ $strlen -gt "23" ]; then
	local width_=$(echo $width-10 | bc)
	local ssid_fixed=$(echo $ssid | cut -c 1-$width_)"..."
	ssid="$ssid_fixed"
        strlen=$(echo -n $ssid | wc -c)
    fi

}

echo "Scanning in progress, please wait..."

sudo rm -r $tempdir/scan $tempdir/scan.list
mkdir $tempdir/scan
cd $tempdir/scan
sudo iwlist $wireless0  scanning | grep -e ESSID -e Quality | split -l 2
ls -l $tempdir/scan | awk '{print $9}' | grep . > $tempdir/scan.list

while read line; do

    mod="3"
    width="23"

    act=$(cat $tempdir/scan/$line | head -n 1 | awk '{print $1}' | awk -F "=" '{print $2}' | awk -F "/" '{print $1}')
    max=$(cat $tempdir/scan/$line | head -n 1 | awk '{print $1}' | awk -F "=" '{print $2}' | awk -F "/" '{print $2}')
    ssid=$(cat $tempdir/scan/$line | head -n 2 | awk -F ":" '{print $2}' | sed 's/"//g' | tr ' ' '_')
    perc=$(echo $act/$max*100 | bc -l | awk -F "." '{print $1}')
    perclenght=$(echo -n $perc | wc -c)
    strlen=$(echo -n $ssid | wc -c)
    lenght=$(echo 100/$mod | bc -l | awk -F "." '{print $1}')
    actlen=$(echo $perc/$mod | bc -l | awk -F "." '{print $1}')

    fix_ssid

    echo -n $ssid
    for i in $(eval echo "{$(echo $strlen+1 | bc)..$width}");do
	echo -n "."
    done

    if [ "$perclenght" == "2" ]; then
	echo -n -e "\t "$perc"% |"
    elif [ "$perclenght" == "3" ]; then 
	echo -n -e "\t"$perc"% |"
    else 
	echo -n -e "\t "$perc"% |"
    fi

    for i in $(eval echo "{1..$lenght}");do
	if [ $i -le $actlen ]; then echo -n "#"; fi
    done

    echo ""

done < $tempdir/scan.list
