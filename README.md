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
<ul>
 <li>ps auxww --sort=-pcpu|head -33</li>
 <li>ps auxww --sort=-rss|head -33</li>
 <li>ps auxww --sort=-vsz|head -33</li>
 <li>ps auxfww</li>
 <li>ps axH|wc -l</li>
 <li>top -w $COLUMNS -b -c -n 2 -i</li>
 <li>free</li>
 <li>vmstat 1 5</li>
 <li>LINES=$(iostat -tNkx|wc -l);iostat -tNkx 2 2|sed -n "$(($LINES+1)),\$p"</li>
 <li>netstat -ntulpae</li>
 <li>netstat -i</li>
 <li>netstat -s</li>
</ul>
