#!/bin/bash

#======CONFIG======#

#Name of the network adapter.
NIC="eth0"

#Set detection cycle,units are seconds.
INTERVAL=10

#Log files in the directory.
LOGDIR="/root/monitor/logs"

#Set the number of log file archiving.
#The logs will be archived once a day.
ROTATE=30

#======SCRIPT======#

[ ! -e $LOGDIR ] && mkdir -p $LOGDIR

cat >/tmp/.monitor-logclear.sh<<EOF
#!/bin/bash
logclear(){
    find $LOGDIR -mtime +$ROTATE -type f -exec rm {} \; >/dev/null 2>&1
}

while :
do
    logclear
    sleep 86401
done
EOF
chmod +x /tmp/.monitor-logclear.sh
/tmp/.monitor-logclear.sh &

LOGCLEAR_PID=$!
sleep 5
LOGCLEAR_SLEEPPID=$(ps ux|grep 'sleep 86401'|grep -v grep|awk '{print $2}')

HOSTNAME=${HOSTNAME:-"$(hostname -f)"}
IP=$(ip addr|grep "scope global $NIC"|awk -F '[ /]+' '{print $3}')
APP_PID=$1
LOGNAME=$(date +%F)

logsupp(){
    echo $TIMESTAMP - $HOSTNAME - $IP - $1 >> $LOGDIR/$LOGNAME.log
}

ps --pid $APP_PID >/dev/null 2>&1

if [ $? -eq 0 ];then
    TIMESTAMP=$(date +"%Y/%m/%d %T")
    logsupp 'Program run!'
    while(($? == 0))
    do
	sleep $INTERVAL
	ps --pid $APP_PID >/dev/null 2>&1
	if(($? != 0));then
	    TIMESTAMP=$(date +"%Y/%m/%d %T")
	    logsupp 'Program out!'
	    kill -9 $LOGCLEAR_PID $LOGCLEAR_SLEEPPID
	    exit
	else
	    TIMESTAMP_NEW=$(date +"%Y/%m/%d %T")
	    sed -i "s@$TIMESTAMP@$TIMESTAMP_NEW@g" $LOGDIR/$LOGNAME.log
	    TIMESTAMP=$TIMESTAMP_NEW
	fi
    done
else
    TIMESTAMP=$(date +"%Y/%m/%d %T")
    logsupp 'Program out!'
    kill -9 $LOGCLEAR_PID $LOGCLEAR_SLEEPPID
fi

