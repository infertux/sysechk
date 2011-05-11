#!/bin/bash

cd "$(dirname $0)/.."

chmod 700 run_tests.sh
chmod 600 README
chmod -R 700 lib
chmod 700 reports
chmod -R 700 tests
chmod 700 tools
chmod 700 tools/build.sh
chmod 400 tools/cce-*.xml
[ -f tools/cce.xml ] && chmod 600 tools/cce.xml
chmod 700 tools/check_env.sh
chmod 600 tools/extract.xslt
chmod 700 tools/fix_perms.sh
[ -d tools/tmp ] && chmod -R 700 tools/tmp

exit 0

