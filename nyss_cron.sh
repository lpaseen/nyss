#!/bin/bash
#
#
#

BASEDIR=${0%/*}
[ "$BASEDIR" == "." ] && BASEDIR=$PWD

[ ! -d $BASEDIR/logs ] && mkdir -p $BASEDIR/logs
NOW=$(date +%A_%H%M)
$BASEDIR/nyss.sh &>$BASEDIR/logs/nyss_cron_$NOW.log
[ ! -s $BASEDIR/logs/nyss_cron_$NOW.log ]  && rm $BASEDIR/logs/nyss_cron_$NOW.log
