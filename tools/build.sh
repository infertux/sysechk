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


CCE=cce-COMBINED-5.20100926.xml
XSLT=extract.xslt
OUT=cce.xml
DIR=tmp

read -p "WARNING: You probably don't want to run this script!
It will overwrite all test templates in $DIR directory.
If you know what you're doing, press 'y' [N/y]: " sure
[ "$sure" = "y" ] || exit 0

cd $(dirname $0)

echo "Transforming $CCE..."
xsltproc -o $OUT $XSLT $CCE

echo "Creating test files in $DIR..."
[ -d "$DIR" ] || mkdir "$DIR"
file=
while read line ; do

    if [ $(echo "$line" | grep -c '^# CCE-ID:') -eq 1 ] ; then
        id=$(echo $line | awk '{print $3}')
        file="$DIR/$id.sh"
        echo "New file: $file"
        touch "$file"
        chmod 700 "$file"
        cat > "$file" <<EOF
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

. \$(dirname \$0)/../lib/functions.sh

EOF
    fi

    if [ -n "$file" ] ; then # start of the file
        if [ -n "$line" ] ; then
            echo "$line" >> "$file"
        else 
            cat >> "$file" <<EOF

echo "This test is not implemented yet." >&2
exit $ret

EOF
        fi
    fi

done < $OUT

