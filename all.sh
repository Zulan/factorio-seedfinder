#!/bin/bash

seq -w 0 1 | parallel ./single.sh # > /dev/null
