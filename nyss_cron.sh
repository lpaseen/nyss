#!/bin/bash


NOW=$(date +%A_%H%M)
$HOME/nyss/nyss.sh &>$HOME/nyss/logs/nyss_cron_$NOW.log
[ ! -s $HOME/nyss/logs/nyss_cron_$NOW.log ]  && rm $HOME/nyss/logs/nyss_cron_$NOW.log
