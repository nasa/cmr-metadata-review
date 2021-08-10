#!/bin/sh
env > /tmp/environment.txt
source /opt/rh/rh-python38/enable
python3 -W ignore lib/dashboard_checker.py $1 $2 2>&1 | tee /tmp/python3_output.txt
