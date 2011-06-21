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
    echo -ne "${REDB}FATAL ERROR:" >&2
    for str ; do
        echo -n " $str" >&2
    done
    echo -e "$DEFAULT" >&2
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
    echo -ne "$RED"
    for str ; do
        echo -n "$str "
    done
    echo -e "$DEFAULT"
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
    [ "$SKIP_ROOT" ] && {
        echo -e "${YELLOWB}$0 skipped because of '-s' option${DEFAULT}" >&2;
        return $E_NORMAL;
    }

    cmd="$@"

    (
        flock -x 200
        if [ "$EXECUTE_ROOT" ]; then
            choice=e
        else
            echo -en "Command ${YELLOW}'${cmd}'${DEFAULT} needs root" \
            "privileges, [e]xecute or [s]kip [s]? " >&2
            read -u 2 choice
            [ -z "$choice" ] && choice=s
        fi

        case $choice in
            e) [ $UID -eq 0 ] && $cmd || sudo -- $cmd ;;
            s|*) echo -e "${YELLOWB}$0 skipped${DEFAULT}" >&2 ;;
        esac
    ) 200>$LOCK_FILE

    return $E_NORMAL

}


# Handle options

while getopts ":hsefv" optval ; do
case $optval in
    "h")
        cat <<HELP
Usage: $(basename $0) [options]
  -h  Display this help
  -s  Skip all tests where root privileges are required (overrides -e)
  -e  Execute all tests where root privileges are required
  -f  Force the program to run even with root privileges
  -v  Be verbose
HELP
        exit 0
        ;;
    "s")
        declare -irx SKIP_ROOT=1
        ;;
    "e")
        declare -irx EXECUTE_ROOT=1
        ;;
    "f")
        declare -irx FORCE_ROOT=1
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


# Check if everything is okay

[[ $UID -eq 0 && -z "$FORCE_ROOT" ]] && FATAL \
"This software does NOT need root privileges, therefore execute it under a" \
"regular user. If you can not login as a normal user (!), you can try:" \
"cd sysechk && chown -R nobody: * .* && sudo -u nobody ./run_tests.sh." \
"If you really want to execute it under root, you can give the '-f' option."

[ "$(find $0 -perm 700)" ] || FATAL "Run tools/fix_perms.sh script first"

