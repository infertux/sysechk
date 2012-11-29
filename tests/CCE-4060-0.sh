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

# CCE-ID: CCE-4060-0
# Orignal-platform: rhel5
# Modified: 2011-10-07
# Description: The system login banner text should be set correctly.
# Parameters: banner text
# Technical-mechanisms: via /etc/motd

. $(dirname $0)/../lib/sysechk.sh

FILE /etc/issue

for pattern in '\\r' "$(uname -r)"; do GREP "$pattern" $file && \
    MAJOR "You should not expose your kernel version ($pattern) through the system login banner, edit $file"
done

for pattern in '\\n' "$(uname -n)"; do GREP "$pattern" $file && \
    MINOR "You should not expose your FQDN ($pattern) through the system login banner, edit $file"
done

case $(DISTRO) in
    redhat)    pattern="$(sed -r 's/^([^ ]+)( .*$)/\1/' /etc/redhat-release)";;
    debian)    pattern="Debian";;
    archlinux) pattern="Arch Linux";;
    *)         pattern="";;
esac

[ "$pattern" ] && GREP "$pattern" $file && \
    MINOR "You should not expose your distribution ($pattern) through the system login banner, edit $file"

exit $ret

