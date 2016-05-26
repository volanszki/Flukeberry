#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
settdir="$basedir/settings"

act_timeout=$(cat $settdir/timeout)

if [ $act_timeout -gt "1" ]; then
    new_timeout=$(echo $act_timeout - 1 | bc)
else
    new_timeout="1"
fi

echo -n $new_timeout > $settdir/timeout
