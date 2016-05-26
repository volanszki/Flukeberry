#!/bin/bash
basedir="$(cat ../settings/basedir)"

newvalue=$(cat $basedir/keyboard/patch.port | rev | cut -c 2- | rev)
echo -n $newvalue > $basedir/keyboard/patch.port
