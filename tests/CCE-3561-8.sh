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

# CCE-ID: CCE-3561-8
# Orignal-platform: rhel5
# Modified: 2010-09-26
# Description: IP forwarding should be enabled or disabled as appropriate.
# Parameters: enabled / disabled
# Technical-mechanisms: via sysctl - net.ipv4.ip_forward

. $(dirname $0)/../lib/sysechk.sh

[ $(/sbin/sysctl -n net.ipv4.ip_forward) -ne 0 ] && MAJOR \
"Is this system going to be used as a firewall or gateway to pass IP traffic" \
"between different networks? If not, add 'net.ipv4.ip_forward = 0' to" \
"/etc/sysctl.conf"

exit $ret

