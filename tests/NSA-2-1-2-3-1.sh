#!/bin/bash

#    This file is part of System Security Checker
#    Copyright (C) 2011  Infertux <infertux@infertux.com>
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

# NSA-ID: NSA-2-1-2-3-1
# Orignal-platform: rhel5
# Modified: 2011-02-28
# Description: Check for package updates.
# Parameters: up-to-date / outdated
# Technical-mechanisms: via yum

. $(dirname $0)/../lib/functions.sh

list=$(yum -q check-update)
[ $? -ne 0 ] && WARNING "Update your packages via 'yum update'"

[ $VERBOSE -ne 0 ] && echo -e "List of available updates:$list"

exit $ret

