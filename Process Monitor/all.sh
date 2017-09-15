#!/bin/bash

sleep 25 &
sh /root/monitor/monitor.sh $! &
