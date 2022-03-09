#!/bin/sh
#if [ -d "/opt/rh/rh-python38" ]; then
#  source /opt/rh/rh-python38/enable
#fi
cat $1 > /tmp/record.txt
echo "python3 -W ignore lib/dashboard_checker.py $1 $2" > /tmp/command.txt
python3 -W ignore lib/dashboard_checker.py $1 $2 > /tmp/output.txt
cat /tmp/output.txt

