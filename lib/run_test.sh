#!/bin/sh
[ -z $REPORTS ] && exit 1
out=$REPORTS/$(basename $1 | cut -d. -f1)
touch $out.tmp
chmod 600 $out.tmp
$1 > $out.tmp
xcode=$?
chmod 400 $out.tmp
mv $out.tmp $out.txt
nb=$(ls $REPORTS/*.txt | wc -w)
[ $xcode -ne 0 ] && last='KO' || last='OK'
echo -ne "$nb tests so far (last: $last)…\r"
exit $xcode

