#!/bin/bash

[ $UID -eq 0 ] && (echo "N0 R00T!" ; kill -SIGKILL $$)

DEFAULT="\e[0m"
RED="\e[31m"
REDB="\e[1;31m"
GREEN="\e[32m"
GREENB="\e[1;32m"

# internal error exit status
INTERNAL=3

declare -i VERBOSE=0
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
        file=$1
        [ -r "$file" ] || FATAL "Unable to read file '$file'."
        shift
    done
}

function GREP
{
    [ $# -lt 1 -o $# -gt 3 ] && exit $INTERNAL

    [ $# -eq 1 ] && file=- <&1
    [ $# -eq 3 ] && (options=$1 ; shift)

    pattern=$1
    file=$2

    grep -Eq $options "$pattern" $file
    return $?
}

while getopts ":vh" optval ; do
case $optval in
    "h")
        cat <<HELP
Usage: $(basename $0) [options]
-h  Display this help
-v  Be verbose
HELP
        exit 0
        ;;
    "v")
        VERBOSE=1
        ;;
    *)
        echo "Unknown parameter: '$OPTARG'"
        exit 1
        ;;
esac
done

