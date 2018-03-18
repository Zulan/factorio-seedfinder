#!/bin/bash

seq -w 10 15 | parallel ./single.sh # > /dev/null
