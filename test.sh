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
echo "cd /root && ./run_tests.sh -fe" | chroot $CHROOT /bin/bash

