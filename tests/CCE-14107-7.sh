#!/bin/bash
# This file is part of System Security Checker

# CCE-ID: CCE-14107-7
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The default umask for all users should be set correctly in /etc/login.defs
# Parameters: umask
# Technical-mechanisms: via /etc/login.def

. $(dirname $0)/../lib/functions.sh

GREP 'UMASK           077' /etc/login.defs || \
    WARNING "Add 'UMASK           077' to $file"

exit $ret

