#!/bin/bash

# Robust scripting
set -eu

# Handle options
SKIP_ROOT=false
EXECUTE_ROOT=false
FORCE_ROOT=false
VERBOSE=false
EXCLUDE_TESTS=''
OUTPUT_FILE=''

while getopts ":hsefx:o:v" optval; do
case $optval in
    h)
        cat >&2 <<HELP
Usage: $(basename $0) [options]
  -h  Display this help
  -s  Skip all tests where root privileges are required (overrides -e)
  -e  Execute all tests where root privileges are required
  -f  Force the program to run even with root privileges
  -v  Be verbose
  -x <test>  Test to exclude (can be repeated, e.g. -x CCE-3561-8 -x NSA-2-1-2-3-1)
  -o <file>  Write the list of failed tests into an output file
HELP
        exit 0 ;;
    s)
        SKIP_ROOT=true ;;
    e)
        EXECUTE_ROOT=true ;;
    f)
        FORCE_ROOT=true ;;
    v)
        VERBOSE=true ;;
    x)
        EXCLUDE_TESTS="${EXCLUDE_TESTS} ${OPTARG} " ;;
    o)
        OUTPUT_FILE=$OPTARG ;;
    *)
        echo "Unknown parameter: '$OPTARG'" >&2
        exit 1 ;;
esac
done

# Check if everything is okay
[[ $UID -eq 0 && ! $FORCE_ROOT ]] && FATAL \
"This software does NOT need root privileges, therefore execute it under a" \
"regular user. If you can not login as a normal user (!), you can try:" \
"cd sysechk && chown -R nobody: * .* && sudo -u nobody ./run_tests.sh." \
"If you really want to execute it under root, you can pass the '-f' option."

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

# Disable CTRL+C
trap '' INT

# Error handler
term() {
    echo "Unexpected termination (exit code: $?)"
    exit $E_INTERNAL
}
trap term TERM

# Init some flags
declare -i ret=0

# Declare functions
# Returns the distribution family (i.e. CentOs and Fedora will return 'redhat')
function DISTRO
{
    [ -e /etc/redhat-release ] && { echo redhat; return; }
    [ -e /etc/debian_version ] && { echo debian; return; }
    [ -e /etc/arch-release ] && { echo archlinux; return; }
    echo unknown
}

function FATAL
{
    echo -ne "${REDB}FATAL ERROR:" >&2
    for str; do
        echo -n " $str" >&2
    done
    echo -e "$DEFAULT" >&2
    exit $E_FATAL
}

function ABORT
{
    echo -e "${REDB}FATAL ERROR: ${1}\nTest $(basename $0) aborted${DEFAULT}" >&2
    exit $E_FATAL
}

function WARNING
{
    ret=$E_NORMAL
    echo -ne "$RED"
    for str; do
        echo -n "$str "
    done
    echo -e "$DEFAULT"
}

function FILE
{
    for f; do
        file=$f
        [ -r "$file" ] || ABORT "Unable to read file '$file'."
        shift
    done
}

function GREP
{
    [ $# -lt 1 -o $# -gt 3 ] && exit $E_INTERNAL

    [ $# -eq 3 ] && { options=$1 ; shift; } || options=--
    [ $# -eq 1 ] && file=- <&1 || { FILE $2; file=$2; }

    pattern=$1

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
    if $SKIP_ROOT; then
        echo -e "${YELLOWB}$0 skipped because of '-s' option${DEFAULT}" >&2
        return 0
    fi

    cmd="$@"

    (
        flock -x 200
        if $EXECUTE_ROOT; then
            choice=e
        else
            echo -en "Command ${YELLOW}'${cmd}'${DEFAULT} needs root" \
            "privileges, [e]xecute or [s]kip [s]? " >&2
            read -u 2 choice
            [ -z "$choice" ] && choice=s
        fi

        case $choice in
            e) [ $UID -eq 0 ] && $cmd || sudo -- $cmd ; return ;;
            s|*) echo -e "${YELLOWB}$0 skipped${DEFAULT}" >&2 ; return 0 ;;
        esac
    ) 200>$LOCK_FILE
}

current_test=$(echo $0 | sed -r 's#tests/(.*)\.sh#\1#')
if [[ "$EXCLUDE_TESTS" =~ " $current_test " ]]; then
    echo EXCLUDED
    $VERBOSE && echo -e "${YELLOWB}$0 excluded${DEFAULT}" >&2
    exit 0
fi

return 0

