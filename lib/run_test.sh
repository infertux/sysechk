#!/bin/bash

# this is a wrapper script, exit if called directly
[[ "$REPORTS" && "$LOCK_FILE" ]] || exit 1

# arguments
file="${@: -1}" # last argument
opts=${@:1:(($#-1))}

# run the test writing output to report
out="$REPORTS/$(basename $file | cut -d. -f1)"
touch $out.tmp
chmod 600 $out.tmp # prevent espionage from other users ;)
$file $opts > $out.tmp
xcode=$?
chmod 400 $out.tmp # lock the file
mv $out.tmp $out.txt

# update status
remain=$(ps --no-headers -o pid --ppid=$PPID | wc -w)
flock -x -n $LOCK_FILE -c "echo -n -e \"${remain} tests remaining \r\""

exit $xcode

