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
echo -ne "$nb tests taken (last: $([ $xcode -ne 0 ] && echo KO || echo OK))\r"
exit $xcode

