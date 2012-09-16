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

# CCE-ID: CCE-4292-9
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: The auditd service should be enabled or disabled as appropriate.
# Parameters: enabled / disabled
# Technical-mechanisms: via chkconfig

. $(dirname $0)/../lib/functions.sh

if [ $REDHAT ]; then
    chkconfig auditd || WARNING \
    "Enable the auditd service with 'chkconfig auditd on'"
elif [ $DEBIAN ]; then
    [ "$(ls /etc/rc?.d/S??auditd 2>/dev/null)" ] || WARNING \
    "Enable the auditd service with 'update-rc.d auditd enable'"
else
    WARNING "Please ensure that the auditd service is enabled"
fi

exit $ret

