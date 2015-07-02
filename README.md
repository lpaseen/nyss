nyss
====

Collect output of some linux commands like ps,free,vmstat,iostat to be used during troubleshooting
Usage:
<pre>
 Download nyss.sh
 save it in your home directory like in ~/nyss
 start it with
    nohup ~/nyss/nyss.sh &>~/nyss/nyss.log &
 files will be saved in ~/nyss/archive-$HOSTNAME/<date>
 after some time each ~/nyss/archive-$HOSTNAME/<date> is compressed to a tar
 file
</pre>

Currently saved is the output of<br>
 ps auxww --sort=-pcpu|head -33<br>
 ps auxww --sort=-rss|head -33<br>
 ps auxww --sort=-vsz|head -33<br>
 ps auxfww<br>
 ps axH|wc -l<br>
 top -w $COLUMNS -b -c -n 2 -i<br>
 free<br>
 vmstat 1 5<br>
 LINES=$(iostat -tNkx|wc -l);iostat -tNkx 2 2|sed -n "$(($LINES+1)),\$p"<br>
 netstat -ntulpae<br>
 netstat -i<br>
 netstat -s<br>
