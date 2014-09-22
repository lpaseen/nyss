nyss
====

Collect output of some linux commands like ps,free,vmstat,iostat to be used during troubleshooting
Usage: 
 Download nyss.sh
 save it in your home directory like in ~/nyss
 start it with
    nohup ~/nyss/nyss.sh &>~/nyss/nyss.log &
 files will be saved in ~/nyss/archive-$HOSTNAME/<date>
 after some time each ~/nyss/archive-$HOSTNAME/<date> is compressed to a tar
 file
 

Currently saved is the output of
 ps auxww --sort=-pcpu|head -33
 ps auxww --sort=-rss|head -33
 ps auxww --sort=-vsz|head -33
 ps auxfww
 ps axH|wc -l
 top -w $COLUMNS -b -c -n 2 -i
 free
 vmstat 1 5
 LINES=$(iostat -tNkx|wc -l);iostat -tNkx 2 2|sed -n "$(($LINES+1)),\$p"
 netstat -ntulpae
 netstat -i
 netstat -s
