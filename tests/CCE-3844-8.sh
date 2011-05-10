#!/bin/bash
# This file is part of System Security Checker

# CCE-ID: CCE-3844-8
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The default umask for all users should be set correctly for the bash shell
# Parameters: umask
# Technical-mechanisms: umask

. $(dirname $0)/../lib/functions.sh

FILE /etc/bashrc

GREP 'umask 077' /etc/bashrc && WARNING "Add '$pattern' to $file"

exit $ret

