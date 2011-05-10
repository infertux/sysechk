#!/bin/bash

[ $UID -eq 0 ] && (echo "N0 R00T!" ; kill -SIGKILL $$)

DEFAULT="\e[0m"
RED="\e[31m"
REDB="\e[1;31m"
GREEN="\e[32m"
GREENB="\e[1;32m"

# internal error exit status
INTERNAL=3

declare -i ret=0

function FATAL
{
    echo -e "$REDB$1$DEFAULT"
}

function WARNING
{
    ret=1
    echo -e "$RED$1$DEFAULT"
}

function FILE
{
    while [ $1 ] ; do
        [ -r "$1" ] || FATAL "Unable to read file '$1'."
        shift
    done
}

function GREP
{
    [ $# -ne 2 -a $# -ne 3 ] && exit $INTERNAL

    [ $# -eq 3 ] && (options=$1 ; shift)

    pattern=$1
    file=$2

    grep -Eq $options "$pattern" "$file"
    return $?
}

