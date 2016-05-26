#!/bin/bash

basedir="$(cat ../settings/basedir)"
settdir="$basedir/settings"
newvalue=$(cat $basedir/keyboard/patch.port | tr '[:upper:]' '[:lower:]')
echo -n $newvalue
 
