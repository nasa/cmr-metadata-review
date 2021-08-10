#!/bin/sh
python3 -W ignore lib/dashboard_checker.py $1 $2 2>&1 | tee /tmp/python3_output.txt
