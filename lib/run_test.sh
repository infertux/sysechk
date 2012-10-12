#!/bin/bash

# this is a wrapper script, exit if called directly
[[ "$REPORTS" && "$LOCK_FILE" ]] || exit 1

# arguments
file=${!#}
opts=${@:1:(($#-1))}

# run the test writing output to report
out="$REPORTS/$(basename $file | cut -d. -f1)"
touch $out.tmp
chmod 600 $out.tmp # prevent espionage from other users ;)
$file $opts > $out.tmp
xcode=$?
chmod 400 $out.tmp # lock the file
mv $out.tmp $out.txt

# get rid of excluded reports
[ "$(cat $out.txt)" = "EXCLUDED" ] && rm -f $out.txt

# update status
nb=$(ls $REPORTS/*.txt | wc -w)
[ $xcode -ne 0 ] && last='failed' || last='passed'
flock -x -n $LOCK_FILE -c "echo -n -e \"$nb tests so far (last: $last)…\r\""

exit $xcode

