#!/bin/sh
#if [ -d "/opt/rh/rh-python38" ]; then
#  source /opt/rh/rh-python38/enable
#fi
#pyenv local 3.10.3
python -W ignore lib/dashboard_checker.py $1 $2
