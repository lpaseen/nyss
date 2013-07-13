#!/bin/bash
#
#Purpose: Save some logs of what the system look like at different points in time
#
#License: GPL
#
#History:
#2013-07-12  Peter Sjoberg <peter.sjoberg@hp.com>
#       Ver alpha 0.01
#
#TODO:
# Add code to have max size of $ARCHIVE and a min free o the disk
#   starting to create oldest files once limit is reached
# Upload files to central location
# Handle errors
# Allow different log interval
# make an rpm
#
#$Id:$
#


BASEDIR=${0%/*}
BASENAME=$(basename $0 .sh)
[ "${BASEDIR}" == "." ] && BASEDIR=$PWD

LOGDIR=$BASEDIR/logs
ARCHIVE=$BASEDIR/archive
[ ! -d $LOGDIR ] && mkdir -p $LOGDIR
[ ! -d $LOGDIR ] && echo "ERROR, can't create LOGDiR $LOGDIR - ABORT" && exit 90

[ ! -d $ARCHIVE ] && mkdir -p $ARCHIVE
[ ! -d $ARCHIVE ] && echo "ERROR, can't create ARCHIVE $ARCHIVE - ABORT" && exit 91


LOGFILE=$LOGDIR/$BASENAME.log
PIDFILE=/var/run/$BASENAME.pid
[ -w /var/run ] && PIDFILE=/var/run/$BASENAME.pid || PIDFILE=${TMPDIR:=$HOME/tmp}/$BASENAME.pid

[ ! -d ${PIDFILE%/*} ] && mkdir -p ${PIDFILE%/*}
[ ! -d ${PIDFILE%/*} ] && echo "ERROR, can't save pid file in ${PIDFILE%/.*} - ABORT" && exit 92

#check that it's not already running
MYPID=$$
NOWSTAT="$(date +%F\ %T)"
if ( set -o noclobber; echo "$MYPID" > "$PIDFILE") 2> /dev/null; then
    echo "$NOWSTAT; Created lockfile $PIDFILE for PID $MYPID" >>$LOGFILE
else
    # Is it a correct pid ?
    if  strings /proc/$(cat $PIDFILE)/cmdline|grep -q ${0##*/};then
        echo "$NOWSTAT; Lockfile $PIDFILE FOUND, ABORT" >>$LOGFILE
        ps -p $(cat $PIDFILE) >>$LOGFILE 2>&1
        exit
    else
        echo "Stale pidfile found, deleting it." >>$LOGFILE 
        echo "$MYPID" > "$PIDFILE"
    fi
fi

trap "rm -f $PIDFILE; exit" INT TERM

#Default values, can be overridden later
DEFINTERVAL=60 # unit seconds, save every 60 secods
DEFRETENTION=$((24*2)) # unit hours, keep 2 days

################################################################
#Run a command and save the data to a logfile
#
CollectData(){
    logname="$1"
    RET="$2"
    cmd="$3"
    eval "$cmd" >>$ARCHIVE/${logname}_$NOW.log 2>&1
    find $ARCHIVE/ -name "${logname}_*.log" -mtime +$(($RET*60))
} # CollectData


################################################################
################
# Main loop to collect data
#
# could do something fancy and keep track of when last one was done
# and then make it possible to run one every 10 sec and some other every 600sec
# but for now we keep down the load with just a simple "sleep 60"
#

echo "Saving log to $LOGFILE"
echo "Saving archive to $ARCHIVE"
while  [ -e "${PIDFILE}" ];do
    NOW=$(date +%F_%H%M%S)
    CollectData ps_auxwww_pcpu $DEFRETENTION "ps auxww --sort=-pcpu|head -33"
    CollectData ps_auxwww_rss  $DEFRETENTION "ps auxww --sort=-rss|head -33"
    CollectData ps_auxwww_vsz  $DEFRETENTION "ps auxww --sort=-vsz|head -33"
    CollectData top            $DEFRETENTION "top -b -c -n 2 -i"
    CollectData free           $DEFRETENTION "free"
    CollectData vmstat         $DEFRETENTION "vmstat 1 5"
    CollectData iostat         $DEFRETENTION 'LINES=$(iostat -tNkx|wc -l);iostat -tNkx 2 2|sed -n "$(($LINES+1)),\$p"'
#
    CollectData netstat_a $DEFRETENTION "netstat -ntulpae"
    CollectData netstat_i $DEFRETENTION "netstat -i"
    CollectData netstat_s $DEFRETENTION "netstat -s"
    sleep $DEFINTERVAL
done
rm -f $PIDFILE
