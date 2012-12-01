#!/bin/bash

set -eu

[ $UID -eq 0 ] || exit 1
cd $(dirname $0)/..

# 1. Run it locally
./sysechk -f || true

# 2. Run it into a chrooted Debian
CHROOT=chroot
[ -d $CHROOT ] || debootstrap stable $CHROOT

# Setup
cat > $CHROOT/etc/fstab <<CONF
proc /proc proc defaults 0 0
CONF
chroot $CHROOT mount -a

# Copy itself into the chroot
rsync -a --exclude chroot . $CHROOT/root/

# Assert we have the expected failing tests
echo "cd /root && ./sysechk -f -o list" | chroot $CHROOT /bin/bash || true
echo "
CCE-14011-1
CCE-14107-7
CCE-14161-4
CCE-14777-7
CCE-4060-0
CCE-4292-9
" | diff -B <(sort ${CHROOT}/root/list) -

# Assert we have no critical failing tests
echo "cd /root && ./sysechk -f -o list -m critical" | chroot $CHROOT /bin/bash || true
[ ! -s ${CHROOT}/root/list ]

echo OK

