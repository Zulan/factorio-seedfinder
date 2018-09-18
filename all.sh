#!/bin/bash

seq -w 0 3 | parallel ./single.sh # > /dev/null
