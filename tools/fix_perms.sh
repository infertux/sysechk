#!/bin/bash

cd "$(dirname $0)/.."

chmod 700 *.sh
chmod 400 README
chmod -R 700 lib
chmod 700 reports
chmod -R 400 reports/*
chmod -R 700 tests
chmod 700 tools
chmod 700 tools/*.sh
chmod 700 tools/dev
chmod 700 tools/dev/*.sh
[ -f tools/dev/cce.xml ] && chmod 600 tools/dev/cce.xml
chmod 400 tools/dev/cce-*.xml
chmod 600 tools/dev/extract.xslt
[ -d tools/dev/tmp ] && chmod -R 700 tools/dev/tmp

exit 0

