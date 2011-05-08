#!/bin/bash

CCE=cce-COMBINED-5.20100926.xml
XSLT=extract.xslt
OUT=cce.xml
DIR=../tests

echo "Transforming $CCE..."
xsltproc -o $OUT $XSLT $CCE

echo "Creating test files in $DIR..."
file=
while read line ; do

    if [ $(echo "$line" | grep -c '^# CCE-ID:') -eq 1 ] ; then
        id=$(echo $line | awk '{print $3}')
        file="$DIR/$id.sh"
        echo "New file: $file"
        cat > "$file" <<EOF
#!/bin/bash
# This file is part of System Security Checker

EOF
        chmod 744 "$file"
    fi

    if [ -n "$file" ] ; then # start of the file
        if [ -n "$line" ] ; then
            echo "$line" >> "$file"
        else 
            cat >> "$file" <<EOF

echo "This test is not implemented yet." >&2
exit 1
EOF
        fi
    fi

done < $OUT

