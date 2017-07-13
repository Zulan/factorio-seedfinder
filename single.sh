#!/bin/bash

# The factorio folder must be in this level of the path
FACTORIO=./factorio_alpha_x64_0.15.27/bin/x64/factorio
DIR="local/$1"
SEED="1${1}000000"
mkdir -p $DIR
sed -e "s/NNNNNN/${1}/g" settings/config.ini.tmpl > $DIR/config.ini
$FACTORIO -c $DIR/config.ini --create $DIR/tmp --mod-directory mods --map-settings settings/map-settings.json --map-gen-settings settings/map-gen-settings.json --map-gen-seed $SEED
$FACTORIO -c $DIR/config.ini --start-server $DIR/tmp --mod-directory mods --server-settings settings/server-settings.json --bind 127.0.0.1:341${1}
