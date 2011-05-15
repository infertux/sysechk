#!/bin/bash

# Declare constants

DEFAULT="\e[0m"
RED="\e[31m"
REDB="\e[1;31m"
GREEN="\e[32m"
GREENB="\e[1;32m"

E_NORMAL=1 # exit code for "normal" errors
E_FATAL=2 # exit code for fatal errors
E_INTERNAL=3 # exit code for internal errors

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
    exit $E_FATAL
}

function ABORT
{
    echo -e "${REDB}FATAL ERROR: ${1}\nTest $(basename 0) aborted${DEFAULT}"
    exit $E_FATAL
}

function WARNING
{
    ret=$E_NORMAL
    for str ; do
        echo -e "${RED}${str}${DEFAULT}"
    done
}

function FILE
{
    for f ; do
        file=$f
        [ -r "$file" ] || ABORT "Unable to read file '$file'."
        shift
    done
}

function GREP
{
    [ $# -lt 1 -o $# -gt 3 ] && exit $E_INTERNAL

    [ $# -eq 1 ] && file=- <&1
    [ $# -eq 3 ] && (options=$1 ; shift)

    pattern=$1
    file=$2

    grep -Eq $options "$pattern" $file
    return $?
}

function INSTALLED
{
    [ $# -ne 1 ] && exit $E_INTERNAL

    which "$1" >/dev/null 2>&1
    return $?
}

# Check if everything is okay

[ $UID -eq 0 ] && FATAL "
This software does NOT need root privileges, therefore execute it under a
regular user. If you can not login as a normal user (!), you can try:
cd sysechk && chown -R nobody: * && su -c ./run_tests.sh nobody"

[ "$(find $0 -perm 700)" ] || FATAL "Run tools/fix_perms.sh script first"

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

