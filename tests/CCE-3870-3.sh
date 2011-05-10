#!/bin/bash
# This file is part of System Security Checker

# CCE-ID: CCE-3870-3
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The default umask for all users should be set correctly
# Parameters:
# Technical-mechanisms:

. $(dirname $0)/../lib/functions.sh

for file in /etc/profile.d/* ; do
    GREP 'umask' "$file" && (GREP 'umask 077' "$file" || \
        WARNING "Add or correct the line 'umask 077' in $file")
done

exit $ret

