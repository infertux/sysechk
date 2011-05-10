#!/bin/bash
# This file is part of System Security Checker

# CCE-ID: CCE-14161-4
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: /tmp should be configured on an appropriate filesystem partition.
# Parameters: partition
# Technical-mechanisms: via /etc/fstab

. $(dirname $0)/../lib/functions.sh

mount | GREP 'on /tmp ' || \
    WARNING "Create separate partition or logical volume for /tmp"

exit $ret

