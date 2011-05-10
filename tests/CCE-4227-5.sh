#!/bin/bash
# This file is part of System Security Checker

# CCE-ID: CCE-4227-5
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The default umask for all users should be set correctly for the csh shell
# Parameters:
# Technical-mechanisms:

. $(dirname $0)/../lib/functions.sh

FILE /etc/csh.cshrc /etc/csh.login

GREP 'umask 077' /etc/csh.cshrc && WARNING "Add '$pattern' to $file"
GREP 'umask' /etc/csh.login && (GREP -v 'umask 077' /etc/csh.login || \
    WARNING "umask is not set to 077 in $file")

exit $ret

