#!/bin/bash

DIR=tests

for file in $DIR/* ; do
    id=$(grep '^# CCE-ID: ' "$file" | cut -d' ' -f3)
    echo "Running test $id..."
    grep '^# Description: ' "$file" | cut -d' ' -f3-
    "./$file"
    echo
done

