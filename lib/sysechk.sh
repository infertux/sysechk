#!/bin/bash

#########
# SETUP #
#########

set -eu

# Disable CTRL+C
trap '' INT

# Error handler
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

# misc
declare -rx LOCK_FILE=.lock


#############
# FUNCTIONS #
#############

# severity helpers

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


# colored message helpers

# Handy helper to display a warning message
function WARNING
{
    echo -e "${COLOR[red]}$@${COLOR[default]}"
}

# Handy helper to display a notice message
function NOTICE
{
    echo -e "${COLOR[yellow]}$@${COLOR[default]}"
}

# Handy helper to display a success message
function SUCCESS
{
    echo -e "${COLOR[green]}$@${COLOR[default]}"
}

# test helpers

# Returns the distribution family (i.e. CentOs and Fedora will return 'redhat')
function DISTRO
{
    [ -e /etc/redhat-release ] && { echo redhat; return; }
    [ -e /etc/debian_version ] && { echo debian; return; }
    [ -e /etc/arch-release ] && { echo archlinux; return; }
    echo unknown
}

# Any fatal error to the program
function FATAL
{
    echo -e "${COLOR[red_bold]}FATAL ERROR: $@${COLOR[default]}" >&2
    exit $E_FATAL
}

# Abort a test which cannot complete
function ABORT
{
    echo -e "${COLOR[red_bold]}FATAL ERROR: ${1}\nTest $(basename $0) aborted${COLOR[default]}" >&2
    exit $E_FATAL
}

# Abort if any given file is not readable
function FILE
{
    for f; do
        file=$f
        [ -r "$file" ] || ABORT "Unable to read file '$file'."
        shift
    done
}

# Sweet grep wrapper
function GREP
{
    [ $# -lt 1 -o $# -gt 3 ] && exit $E_INTERNAL

    [ $# -eq 3 ] && { options=$1 ; shift; } || options=--
    [ $# -eq 1 ] && file=- <&1 || { FILE $2; file=$2; }

    pattern=$1

    grep -Eq $options "$pattern" $file
    return
}

# Test if a program/command is installed and available
function INSTALLED
{
    [ $# -ne 1 ] && exit $E_INTERNAL

    which "$1" &>/dev/null
    return
}

# Interactive sudo wrapper which handles concurrent calls
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


################
# DEPENDENCIES #
################

chk_cmd()
{
    for cmd; do
        command -v $cmd >/dev/null || \
            FATAL "Command \`$cmd' not found in 'PATH=$PATH'" >&2
    done
}

chk_cmd find grep mv rm sed sudo /sbin/sysctl xargs
case $(DISTRO) in
    redhat) chk_cmd yum;;
    debian) chk_cmd apt-get;;
    archlinux) chk_cmd pacman;;
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

while getopts ":hsefvx:o:m:" optval; do
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
  -m (trivial|minor|major|critical) Minimal severity to report
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
    m)
        set +u
        if [ "${SEVERITY[$OPTARG]}" ]; then
           MINIMAL_SEVERITY=${SEVERITY[$OPTARG]}
        else
           FATAL "Severity is invalid." >&2
        fi
        set -u
        ;;
    *)
        FATAL "Unknown parameter: '$OPTARG'" >&2 ;;
esac
done


########
# MISC #
########

# Check we're not root unless explicitly allowed
[ $UID -ne 0 ] || $FORCE_ROOT || FATAL \
"This software does NOT need root privileges, therefore execute it under a" \
"regular user. If you can not login as a normal user (!), you can try:" \
"cd sysechk && chown -R nobody: * .* && sudo -u nobody ./run_tests.sh." \
"If you really want to execute it under root, you can pass the '-f' option."

# Handle excluded tests
current_test=$(echo $0 | sed -r 's#tests/(.*)\.sh#\1#')
if [[ "$EXCLUDE_TESTS" =~ " $current_test " ]]; then
    $VERBOSE && NOTICE "$0 excluded" >&2
    exit 0
fi

return 0

