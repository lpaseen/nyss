#!/bin/bash


NOW=$(date +%A_%H%M)
/home/peters/nyss/nyss.sh &>/home/peters/nyss/logs/nyss_cron_$NOW.log
[ ! -s /home/peters/nyss/logs/nyss_cron_$NOW.log ]  && rm /home/peters/nyss/logs/nyss_cron_$NOW.log
