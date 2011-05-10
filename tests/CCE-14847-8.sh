#!/bin/bash
# This file is part of System Security Checker

# CCE-ID: CCE-14847-8
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The default umask for all users should be set correctly in /etc/profile
# Parameters: umask
# Technical-mechanisms: via /etc/profile

. $(dirname $0)/../lib/functions.sh

FILE /etc/profile

GREP 'umask 077' /etc/profile || \
    WARNING "Add 'umask 077' to $file"

exit $ret

