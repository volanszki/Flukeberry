#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
tempdir="$basedir/tmp"

vendor=$(grep -i $1 $funcdir/mac_vendor.db | awk -F ';' '{print $2}' | tr '[:upper:]' '[:lower:]')
echo $vendor
