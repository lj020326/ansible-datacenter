#!/usr/bin/env bash

DATADIR=/tmp

grep "connect from" /var/log/mail.log | grep -vi disconnect > $DATADIR/connectfrom.txt
cat $DATADIR/connectfrom.txt | cut -d" " -f8 > /tmp/connectfrom2.txt

#cat connectfrom2.txt | sort | uniq -c | sort -nr  > $DATADIR/connectfromfreq.txt
cat $DATADIR/connectfrom2.txt | sort | uniq -c | sort -nr | more

