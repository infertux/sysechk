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

function chk_fn()
{
    while [ $1 ] ; do
        [ $(which "$1" 2>/dev/null) ] || \
            echo "Command '$1' not found in 'PATH=$PATH'" >&2
        shift
    done
}

chk_fn rm mv find xargs grep sed
[ $REDHAT ] && chk_fn yum
[ $DEBIAN ] && chk_fn apt-get

echo "Done."

