#!/bin/bash
#
#  */5 * * * * /home/peters/nyss/nyss_cron.sh
#

BASEDIR=${0%/*}
[ "$BASEDIR" == "." ] && BASEDIR=$PWD

[ ! -d $BASEDIR/logs ] && mkdir -p $BASEDIR/logs
NOW=$(date +%A_%H%M)
$BASEDIR/nyss.sh &>$BASEDIR/logs/nyss_cron_$NOW.log
#remove empty files
[ ! -s $BASEDIR/logs/nyss_cron_$NOW.log ]  && [ -e $BASEDIR/logs/nyss_cron_$NOW.log ] && rm $BASEDIR/logs/nyss_cron_$NOW.log
