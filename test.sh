#!/bin/bash

set -eu

[ $UID -eq 0 ] || exit 1
cd $(dirname $0)

# 1. Run it locally
./run_tests.sh -fe || true

# 2. Run it into a chrooted Debian
CHROOT=$(dirname $0)/chroot
[ -d $CHROOT ] || debootstrap stable $CHROOT

# Setup
cat > $CHROOT/etc/fstab <<CONF
proc /proc proc defaults 0 0
CONF
chroot $CHROOT mount -a

# Copy itself into the chroot
rsync -a --exclude chroot . $CHROOT/root/

# Run it
echo "cd /root && ./run_tests.sh -fe -o list" | chroot $CHROOT /bin/bash || true

# Assert we have the expected failed tests
echo "
CCE-14011-1
CCE-14107-7
CCE-14161-4
CCE-14777-7
CCE-4060-0
CCE-4292-9
" | diff -B <(sort ${CHROOT}/root/list) -

