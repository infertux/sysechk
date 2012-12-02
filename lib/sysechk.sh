#!/bin/bash

#########
# SETUP #
#########

set -eu

# disable CTRL+C
trap '' INT

# error handler
term() {
    echo "Unexpected termination (exit code: $?)"
    exit
}
trap term TERM

#############
# CONSTANTS #
#############

# errors
declare -ir E_FATAL=1     # exit code for fatal errors
declare -ir E_INTERNAL=2  # exit code for internal errors, i.e. bugs

# colors
declare -A COLOR
COLOR=([default]="\e[0m" [red]="\e[31m" [red_bold]="\e[1;31m" [yellow]="\e[33m" [yellow_bold]="\e[1;33m" [green]="\e[32m" [green_bold]="\e[1;32m")

# problem severities which can be returned by tests
declare -A SEVERITY
SEVERITY=([ok]=0 [trivial]=1 [minor]=2 [major]=3 [critical]=4)

declare -A SEVERITY_COLOR
SEVERITY_COLOR=([ok]=green [trivial]=yellow [minor]=yellow_bold [major]=red [critical]=red_bold)

# default
declare -i ret=${SEVERITY[ok]}

# lock file for flock
declare -rx LOCK_FILE=.lock


#############
# FUNCTIONS #
#############

## severity helpers

set_exit_code() {
    # keep the most critical code (biggest number) or OK
    [ $1 -gt $ret -o $1 -eq ${SEVERITY[ok]} ] && ret=$1
}

set_severity() {
    local severity=$1
    shift

    [ $MINIMAL_SEVERITY -le ${SEVERITY[$severity]} ] || return
    echo -e "${COLOR[${SEVERITY_COLOR[$severity]}]}${severity^}: $@${COLOR[default]}"
    set_exit_code ${SEVERITY[$severity]}
}

CRITICAL() {
    set_severity critical $@
}

MAJOR() {
    set_severity major $@
}

MINOR() {
    set_severity minor $@
}

TRIVIAL() {
    set_severity trivial $@
}


## colored message helpers

# handy helper to display a warning message
function WARNING
{
    echo -e "${COLOR[red]}$@${COLOR[default]}"
}

# handy helper to display a notice message
function NOTICE
{
    echo -e "${COLOR[yellow]}$@${COLOR[default]}"
}

# handy helper to display a success message
function SUCCESS
{
    echo -e "${COLOR[green]}$@${COLOR[default]}"
}

## test helpers

# returns the distribution family (i.e. CentOs and Fedora will return 'redhat')
function DISTRO
{
    [ -e /etc/redhat-release ] && { echo redhat; return; }
    [ -e /etc/debian_version ] && { echo debian; return; }
    [ -e /etc/arch-release ] && { echo archlinux; return; }
    echo unknown
}

# any fatal error to the program
function FATAL
{
    echo -e "${COLOR[red_bold]}FATAL ERROR: $@${COLOR[default]}" >&2
    exit $E_FATAL
}

# abort a test which cannot complete
function ABORT
{
    echo -e "${COLOR[red_bold]}FATAL ERROR: ${1}\nTest $(basename $0) aborted${COLOR[default]}" >&2
    exit $E_FATAL
}

# abort if any given file is not readable
function FILE
{
    for f; do
        file=$f
        [ -r "$file" ] || ABORT "Unable to read file '$file'."
        shift
    done
}

# sweet grep wrapper
function GREP
{
    [ $# -lt 1 -o $# -gt 3 ] && exit $E_INTERNAL

    [ $# -eq 3 ] && { options=$1 ; shift; } || options=--
    [ $# -eq 1 ] && file=- <&1 || { FILE $2; file=$2; }

    pattern=$1

    grep -Eq $options "$pattern" $file
    return
}

# test if a program/command is installed and available
function INSTALLED
{
    [ $# -ne 1 ] && exit $E_INTERNAL

    which "$1" &>/dev/null
    return
}

# interactive sudo wrapper which handles concurrent calls
function SUDO
{
    if $SKIP_ROOT; then
        NOTICE "$0 skipped because '-s' flag has been set" >&2
        return 1
    fi

    cmd="$@"

    (
        flock -x 200
        if $EXECUTE_ROOT; then
            choice=e
        else
            echo -en "Command ${COLOR[yellow_bold]}\`${cmd}'${COLOR[default]}" \
            "needs root privileges, [e]xecute or [s]kip [s]? " >&2
            read -u 2 choice
            [ -z "$choice" ] && choice=s
        fi

        case $choice in
            e) [ $UID -eq 0 ] && $cmd || sudo -- $cmd ; return ;;
            s|*) NOTICE "$0 skipped" >&2 ; return 1 ;;
        esac
    ) 200>$LOCK_FILE
}

usage() {
    cat >&2 <<USAGE
Usage: $(basename $0) [OPTION]...
  -h  Display this help
  -s  Skip all tests where root privileges are required (overrides -e)
  -e  Execute all tests where root privileges are required
  -f  Force the program to run even with root privileges (implies -e)
  -v  Be verbose
  -x <test>  Test to exclude (can be repeated, e.g. -x CCE-3561-8 -x NSA-2-1-2-3-1)
  -o <file>  Write the list of failed tests into an output file
  -m (trivial|minor|major|critical) Minimal severity to report
USAGE

    exit 1
}


################
# DEPENDENCIES #
################

check_command()
{
    for cmd; do
        command -v $cmd >/dev/null || \
            FATAL "Command \`$cmd' not found in 'PATH=$PATH'" >&2
    done
}

check_command find grep mv rm sed /sbin/sysctl xargs
case $(DISTRO) in
    redhat) check_command yum;;
    debian) check_command apt-get;;
    archlinux) check_command pacman;;
esac


###########
# OPTIONS #
###########

# FIXME: tedious, get rid of those vars
SKIP_ROOT=false
EXECUTE_ROOT=false
FORCE_ROOT=false
VERBOSE=false
EXCLUDE_TESTS=''
OUTPUT_FILE=''
MINIMAL_SEVERITY=${SEVERITY[trivial]}

ARGS=$(getopt -uo "h,s,e,f,v,x:,o:,m:" -l "help,verbose,version,skip-root,execute-root,force-root,exclude:,output-file:,minimal-severity:" -n sysechk -- "$@")
[ $? -ne 0 ] && usage

eval set -- "$ARGS"
while true; do
    case "$1" in
    -h|--help)
        usage;;
    -s|--skip-root)
        SKIP_ROOT=true
        shift;;
    -e|--execute-root)
        EXECUTE_ROOT=true
        shift;;
    -f|--force-root)
        FORCE_ROOT=true
        EXECUTE_ROOT=true
        shift;;
    -v|--verbose)
        VERBOSE=true
        shift;;
    -x|--exclude)
        EXCLUDE_TESTS="${EXCLUDE_TESTS} $2 "
        shift 2;;
    -o|--output-file)
        OUTPUT_FILE=$2
        shift 2;;
    -m|--minimal-severity)
        set +u
        if [ "${SEVERITY[$2]}" ]; then
           MINIMAL_SEVERITY=${SEVERITY[$2]}
        else
           FATAL "Severity is invalid." >&2
        fi
        set -u
        shift 2;;
    --version)
        echo "sysechk version 0.9" >&2
        exit 0;;
    --)
        shift; break;;
    *)
        FATAL "Unknown parameter: \`$1'" >&2 ;;
    esac
done


########
# MISC #
########

# Check we're not root unless explicitly allowed
[ $UID -ne 0 ] || $FORCE_ROOT || FATAL \
"This software does NOT need root privileges to run." \
"If you really want to execute it under the root user, you can pass the '-f' flag."

# Handle excluded tests
current_test=$(echo $0 | sed -r 's#tests/(.*)\.sh#\1#')
if [[ "$EXCLUDE_TESTS" =~ " $current_test " ]]; then
    $VERBOSE && NOTICE "$0 excluded" >&2
    exit 0
fi

return 0

