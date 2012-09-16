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

. $(dirname $0)/../lib/functions.sh

chk_cmd()
{
    for cmd; do
        command -v $cmd >/dev/null || \
            WARNING "Command '$cmd' not found in 'PATH=$PATH'" >&2
    done
}

chk_cmd find grep mv rm sed sudo /sbin/sysctl xargs
case $(DISTRO) in
    redhat) chk_cmd yum;;
    debian) chk_cmd apt-get;;
    archlinux) chk_cmd pacman;;
esac

echo "Done."

