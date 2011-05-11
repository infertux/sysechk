#!/bin/bash

# Declare constants

DEFAULT="\e[0m"
RED="\e[31m"
REDB="\e[1;31m"
GREEN="\e[32m"
GREENB="\e[1;32m"

FATAL=2 # exit code for fatal errors
INTERNAL=3 # exit code for internal errors

# Guess the current OS

[ -e /etc/redhat-release ] && REDHAT=1
[ -e /etc/debian_version ] && DEBIAN=1

# Init some flags

declare -i VERBOSE=0
declare -i ret=0

# Declare functions

function FATAL
{
    echo -e "${REDB}FATAL ERROR: ${1}${DEFAULT}" >&2
    exit $FATAL
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

# Check if everything is okay

[ $UID -eq 0 ] && FATAL "N0 R00T!"

[ $(ls -l $0 | cut -d' ' -f1) != "-rwx------." ] && \
    FATAL "Run tools/fix_perms.sh script first"

# Handle options

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

