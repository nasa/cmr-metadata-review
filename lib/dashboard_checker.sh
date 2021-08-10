#!/bin/sh
if [ -n "$bamboo_RH_PYTHON3_ENABLE" ]; then
  source /opt/rh/rh-python38/enable
fi
python3 -W ignore lib/dashboard_checker.py $1 $2 2>&1 | tee /tmp/python3_output.txt
