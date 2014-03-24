#!/bin/bash
#
#Purpose: Save some logs of what the system look like at different points in time
#
#License: GPL
#
#History:
#2013-07-12  Peter Sjoberg <peter.sjoberg@hp.com>
#       Ver alpha 0.01
#2013-07-23  Peter Sjoberg <peter.sjoberg@hp.com>
#	Fixed up misc bugs, added "ps auxf" and "top"
#2013-09-02  Peter Sjoberg <peter.sjoberg@hp.com>
#	datestamp the archive directory
#2014-03-23  Peter Sjoberg <peter.sjoberg@hp.com>
#	Add hostname to archive directory
#	if /var/run isn't writable, keep the pidfile to $BASEDIR/run
#
#TODO:
# Add code to have max size of $ARCHIVE and a min free on the disk
#   starting to delete oldest files once limit is reached
# Upload files to central location
# Handle errors
# Allow different log interval
# make an rpm
#
#$Id:$
#


BASEDIR=${0%/*}
BASENAME=$(basename $0 .sh)
[ "$BASEDIR" == ${0} ] && BASEDIR=$PWD
[ "${BASEDIR}" == "." ] && BASEDIR=$PWD

LOGDIR=$BASEDIR/logs
ARCHIVE=$BASEDIR/archive-${HOSTNAME%%.*}
[ ! -d $LOGDIR ] && mkdir -p $LOGDIR
[ ! -d $LOGDIR ] && echo "ERROR, can't create LOGDiR $LOGDIR - ABORT" && exit 90

[ ! -d $ARCHIVE ] && mkdir -p $ARCHIVE
[ ! -d $ARCHIVE ] && echo "ERROR, can't create ARCHIVE $ARCHIVE - ABORT" && exit 91


LOGFILE=$LOGDIR/$BASENAME.log
PIDFILE=/var/run/$BASENAME.pid
[ -w /var/run ] && PIDFILE=/var/run/$BASENAME.pid || PIDFILE=${BASEDIR}/run/$BASENAME.pid
[ ! -d ${PIDFILE%/*} ] && mkdir -p ${PIDFILE%/*}
[ ! -d ${PIDFILE%/*} ] && echo "ERROR, can't save pid file in ${PIDFILE%/.*} - ABORT" && exit 92

#check that it's not already running
MYPID=$$
NOWSTAT="$(date +%F\ %T)"
if ( set -o noclobber; echo "$MYPID" > "$PIDFILE") 2> /dev/null; then
    echo "$NOWSTAT; Created lockfile $PIDFILE for PID $MYPID" >>$LOGFILE
else
    # already three, is it a valid pid ?
    if  strings /proc/$(cat $PIDFILE)/cmdline|grep -q ${0##*/};then
	if [ -n "$VERBOSE" ];then
            echo "$NOWSTAT; Lockfile $PIDFILE FOUND, ABORT" >>$LOGFILE
            ps -p $(cat $PIDFILE) >>$LOGFILE 2>&1
	fi
        exit
    else
        echo "Stale pidfile found, deleting it." >>$LOGFILE 
        echo "$MYPID" > "$PIDFILE"
    fi
fi

trap "rm -f $PIDFILE; exit" INT TERM


#set up a few more columns for apps that limits the output
export COLUMNS=511


#Default values, can be overridden later
DEFINTERVAL=60 # unit seconds, save every 60 secods
DEFRETENTION=$((24*2)) # hours, keep 2 days

################################################################
#Run a command and save the data to a logfile
#
CollectData(){
    logname="$1"
    RET="$2"
    cmd="$3"
    [ ! -d $ARCHIVE/${TODAY} ] && mkdir -p $ARCHIVE/${TODAY}
    eval "$cmd" >>$ARCHIVE/${TODAY}/${logname}_$NOW.log 2>&1
    find $ARCHIVE/ -name "${logname}_*.log" -mmin +$(($RET*60)) -exec rm "{}" \;
} # CollectData


################################################################
################
# Main loop to collect data
#
# could do something fancy and keep track of when last one was done
# and then make it possible to run one every 10 sec and some other every 600sec
# but for now we keep down the load with just a simple "sleep 60"
#

echo $(date +%F\ %T) "Using pid file $PIDFILE"
echo $(date +%F\ %T) "Saving log to $LOGFILE"
echo $(date +%F\ %T) "Saving archive to $ARCHIVE"
while  [ -e "${PIDFILE}" ];do
    NOW=$(date +%F_%H%M%S)
    TODAY=$(date +%F)
    CollectData ps_auxww_pcpu $DEFRETENTION "ps auxww --sort=-pcpu|head -33"
    CollectData ps_auxww_rss  $DEFRETENTION "ps auxww --sort=-rss|head -33"
    CollectData ps_auxww_vsz  $DEFRETENTION "ps auxww --sort=-vsz|head -33"
    CollectData ps_auxfww     $DEFRETENTION "ps auxfww"
    CollectData top           $DEFRETENTION "top -w $COLUMNS -b -c -n 2 -i"
    CollectData free          $DEFRETENTION "free"
    CollectData vmstat        $DEFRETENTION "vmstat 1 5"
    CollectData iostat        $DEFRETENTION 'LINES=$(iostat -tNkx|wc -l);iostat -tNkx 2 2|sed -n "$(($LINES+1)),\$p"'
#
    CollectData netstat_a $DEFRETENTION "netstat -ntulpae"
    CollectData netstat_i $DEFRETENTION "netstat -i"
    CollectData netstat_s $DEFRETENTION "netstat -s"
#
    # delete empty dates directories
    rmdir $ARCHIVE/20[1-9][0-9]-[0-1][0-9]-[0-3][0-9] &>/dev/null # ignore errors due to not empty

    sleep $DEFINTERVAL
done

echo $(date +%F\ %T) "Pidfile gone -Exited while loop"
echo $(date +%F\ %T) "Pidfile gone -Exited while loop" >>$LOGFILE 

#Should never exist
rm -f $PIDFILE
