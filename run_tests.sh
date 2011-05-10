#!/bin/bash

#    This file is part of System Security Checker
#    Copyright (C) 2011  Infertux <infertux@infertux.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

export TESTS=tests
export REPORTS=reports

cd $(dirname $0)
. ./lib/functions.sh

echo "Purging old reports..."
rm -f $REPORTS/*

echo "Running tests..."
find $TESTS -name "*.sh" -print0 | xargs -0 -n1 -P0 ./lib/run_test.sh
xcode=$?

[ $xcode -ne 123 ] && (echo "WTF:$xcode" ; exit 1)

fail=$(find $REPORTS -name "*.txt" -not -empty | wc -l)
reports=$(ls $REPORTS | wc -w)
echo "$reports tests taken in $SECONDS seconds"

if [ $xcode -eq 123 ] ; then
    echo -e "${REDB}$fail problems detected:${DEFAULT}"
    grep '' $REPORTS/*.txt | sed -r 's@.*/(.*)\.txt:(.*)$@\1\t\2@' >&2
fi

echo "Done."

