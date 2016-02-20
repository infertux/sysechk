#!/bin/bash

#    This file is part of System Security Checker
#    Copyright (C) 2011-2016  Infertux <infertux@infertux.com>
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

# CCE-ID: CCE-14927-8
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The noexec option should be enabled or disabled as appropriate for /tmp.
# Parameters: enabled / disabled
# Technical-mechanisms: via /etc/fstab

. $(dirname $0)/../lib/sysechk.sh

FILE /etc/fstab

[ "$(awk '$2=="/tmp" && $4!~"noexec"' $file)" ] && \
    MAJOR "Add the option 'noexec' in column 4 for /tmp in $file"

exit $ret

