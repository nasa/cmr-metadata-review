#!/bin/sh
if [ -n "$bamboo_RH_PYTHON3_ENABLE" ]; then
  source ${bamboo_RH_PYTHON3_ENABLE}
fi
python3 -W ignore lib/dashboard_checker.py $1 $2
