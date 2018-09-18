#!/bin/bash

# The folder must be in this level of the path
F=./0.16.30-head/bin/x64/a.out
DIR="local/$1"
SEED_PREFIX=$((1300+${1}))
SEED="${SEED_PREFIX}00000"
PORT=$((3400 + ${1}))
mkdir -p $DIR
sed -e "s/NNNNNN/${1}/g" settings/config.ini.tmpl > $DIR/config.ini
cp -r mods $DIR/mods
echo "seed_start=${SEED}" > $DIR/mods/seedfinder_0.1.0/seed_start.lua
echo "Starting $1 with seed $SEED"
$F -c $DIR/config.ini --create $DIR/tmp --mod-directory $DIR/mods --map-settings settings/map-settings.json --disable-audio --map-gen-seed $SEED > /dev/null
#taskset -c $1 $F -c $DIR/config.ini --start-server $DIR/tmp --mod-directory $DIR/mods --server-settings settings/server-settings.json --bind 127.0.0.1:${PORT} > /dev/null
taskset -c $1 $F -c $DIR/config.ini --load-game $DIR/tmp --disable-audio --mod-directory $DIR/mods > /dev/null
