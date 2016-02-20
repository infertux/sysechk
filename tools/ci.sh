#!/bin/bash -eux

cd $(dirname $0)/..

DISTRO=${DISTRO:-local}

if [ "$DISTRO" = "local" ]; then # run it locally

  bashcov -- ./sysechk -s || true
  exit 0

fi

# otherwise run it into Docker
docker pull $DISTRO
docker run -v $PWD:/sysechk $DISTRO /sysechk/sysechk -f -x "NSA-2-1-2-3-1" -o /sysechk/list || true
diff -u <(sort list) <(echo $FAILING | tr ' ' '\n' | sort) # assert we have the expected failing tests

docker run -v $PWD:/sysechk $DISTRO /sysechk/sysechk -f -m critical # assert we have no critical tests failing

