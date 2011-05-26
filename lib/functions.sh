#!/bin/bash

# Declare constants

# colors
declare -r DEFAULT="\e[0m"
declare -r RED="\e[31m"
declare -r REDB="\e[1;31m"
declare -r GREEN="\e[32m"
declare -r GREENB="\e[1;32m"
declare -r YELLOW="\e[33m"
declare -r YELLOWB="\e[1;33m"

# errors
declare -ir E_NORMAL=1      # exit code for "normal" errors
declare -ir E_FATAL=2       # exit code for fatal errors
declare -ir E_INTERNAL=3    # exit code for internal errors

# misc
declare -rx LOCK_FILE=.lock

# Guess the current OS

[ -e /etc/redhat-release ] && declare -ir REDHAT=1
[ -e /etc/debian_version ] && declare -ir DEBIAN=1

# Init some flags

declare -i ret=0

# Disable CTRL+C
trap '' SIGINT

# Declare functions

function FATAL
{
    echo -e "${REDB}FATAL ERROR: ${1}${DEFAULT}" >&2
    exit $E_FATAL
}

function ABORT
{
    echo -e "${REDB}FATAL ERROR: ${1}\nTest $(basename 0) aborted${DEFAULT}" >&2
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
    return
}

function INSTALLED
{
    [ $# -ne 1 ] && exit $E_INTERNAL

    which "$1" &>/dev/null
    return
}

function SUDO
{
    [ "$SKIP_ROOT" ] && return $E_NORMAL

    cmd="$@"

    (
        flock -x 200
        echo -en "Command ${YELLOW}'${cmd}'${DEFAULT} needs root privileges, [e]xecute or [s]kip [s]? " >&2
        read -u 2 choice
        [ -z "$choice" ] && choice=s

        case $choice in
            e) sudo -- $cmd ;;
            s|*) ;;
        esac
    ) 200>$LOCK_FILE

    return $E_NORMAL

}


# Check if everything is okay

[ $UID -eq 0 ] && FATAL "
This software does NOT need root privileges, therefore execute it under a
regular user. If you can not login as a normal user (!), you can try:
cd sysechk && chown -R nobody: * && su -c ./run_tests.sh nobody"

[ "$(find $0 -perm 700)" ] || FATAL "Run tools/fix_perms.sh script first"

# Handle options

while getopts ":hsv" optval ; do
case $optval in
    "h")
        cat <<HELP
Usage: $(basename $0) [options]
  -h  Display this help
  -s  Skip all tests where root privileges are required
  -v  Be verbose
HELP
        exit 0
        ;;
    "s")
        declare -irx SKIP_ROOT=1
        ;;
    "v")
        declare -irx VERBOSE=1
        ;;
    *)
        echo "Unknown parameter: '$OPTARG'"
        exit 1
        ;;
esac
done

