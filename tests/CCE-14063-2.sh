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

# CCE-ID: CCE-14063-2
# Orignal-platform: rhel5
# Modified: 2011-10-07
# Description: The password hashing algorithm should be configured as appropriate.
# Parameters: hashing algorithm
# Technical-mechanisms: via PAM

. $(dirname $0)/../lib/sysechk.sh

case $(DISTRO) in
    debian) FILE /etc/pam.d/common-password;;
    *)      FILE /etc/pam.d/system-auth;;
esac

GREP "^password\s+.*\s+pam_unix\.so\s+.*sha512" $file || \
    CRITICAL "Edit the file /etc/pam.d/system-auth to ensure that sha512 is used by the pam unix.so module in the password section"

exit $ret

