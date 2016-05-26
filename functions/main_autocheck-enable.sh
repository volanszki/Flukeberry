#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
scriptname="L2_discovery.service"
already_running=$(ps aux | grep "$scriptname" | grep -v grep | wc -l)

if [ "$already_running" == "1" ]; then
    echo ">>> The process is ALREADY running!"
else
    $funcdir/$scriptname &
    echo ">>> Starting the Auto-checker script..."
fi

