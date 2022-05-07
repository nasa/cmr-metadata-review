#!/bin/sh
#if [ -d "/opt/rh/rh-python38" ]; then
#  source /opt/rh/rh-python38/enable
#fi
pyenv local 2.7.18
python2 -W ignore lib/GranuleChecker.py $1

