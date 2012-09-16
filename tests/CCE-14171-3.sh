#!/bin/bash

#    This file is part of System Security Checker
#    Copyright (C) 2011-2012  Infertux <infertux@infertux.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# CCE-ID: CCE-14171-3
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: /var/log/audit should be configured on an appropriate filesystem partition.
# Parameters: partition
# Technical-mechanisms: via /etc/fstab

. $(dirname $0)/../lib/functions.sh

dir=/var/log/audit
[ -d $dir ] || exit 0

mount | GREP "on $dir " || \
    WARNING "Create separate partition or logical volume for $dir"

exit $ret

