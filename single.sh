#!/bin/bash

# The factorio folder must be in this level of the path
FACTORIO=./0.16.30/bin/x64/factorio
DIR="local/$1"
SEED="${1}00000"
mkdir -p $DIR
sed -e "s/NNNNNN/${1}/g" settings/config.ini.tmpl > $DIR/config.ini
# cp -r mods $DIR/mods
# echo "seed_start=${SEED}" > $DIR/mods/seedfinder_0.1.0/seed_start.lua

$FACTORIO -c $DIR/config.ini --create $DIR/tmp --mod-directory mods --map-settings settings/map-settings.json --map-gen-seed $SEED
$FACTORIO -c $DIR/config.ini --start-server $DIR/tmp --mod-directory mods --server-settings settings/server-settings.json --bind 127.0.0.1:34${1}
