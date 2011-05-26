#!/bin/bash

# this is a wrapper script, exit if called directly
[ -z $REPORTS ] && exit 1
[ -z $LOCK_FILE ] && exit 1

out=$REPORTS/$(basename $1 | cut -d. -f1)
touch $out.tmp
chmod 600 $out.tmp # prevent espionage from other users ;)
$1 > $out.tmp
xcode=$?
chmod 400 $out.tmp # lock the file
mv $out.tmp $out.txt

nb=$(ls $REPORTS/*.txt | wc -w)
[ $xcode -ne 0 ] && last='KO' || last='OK'
# FIXME: run the two lines above in the flock (avoid useless computation)
flock -x -n $LOCK_FILE -c "echo -n -e \"$nb tests so far (last: $last)…\r\""

exit $xcode

