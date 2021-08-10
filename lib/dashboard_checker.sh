#!/bin/sh
python3 --version > '/tmp/prior_python_version.txt'
if [ -n "$bamboo_RH_PYTHON3_ENABLE" ]; then
  source /opt/rh/rh-python38/enable
fi
python3 --version > '/tmp/new_python_version.txt'
python3 -W ignore lib/dashboard_checker.py $1 $2
