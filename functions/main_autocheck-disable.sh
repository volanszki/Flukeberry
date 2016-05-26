#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
scriptname="L2_discovery.service"
already_running=$(ps aux | grep "$scriptname" | grep -v grep | wc -l)

if [ "$already_running" == "1" ]; then
    pidnum=$(ps aux | grep "$scriptname" | grep -v grep | awk '{print $2}')
    echo ">>> Killing process $scriptname (PID: $pidnum)"
    kill $pidnum
else
    echo ">>> Process $scriptname is NOT running..."
fi

