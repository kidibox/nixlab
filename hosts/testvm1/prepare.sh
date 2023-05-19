#!/bin/sh

DISK='@disk@'
MAIN_LABEL='@main@'
ZFS_NIX='@nix@'
ZFS_HOME='@home@'
ZFS_HARDSTATE='@hardstate@'
ZFS_SOFTSTATE='@softstate@'

PARTED='@parted@'
UDEVADM='@udevadm@'
ZPOOL='@zpool@'
ZFS='@zfs@'

echo "Partitioning disk $DISK"
if ! $PARTED --script --align optimal "$DISK" -- \
  mklabel gpt \
  mkpart "$MAIN_LABEL" 1MB 100%; then
  echo "Partitioning failed" >&2
  exit 1
fi

$UDEVADM trigger

printf '%s' "waiting for partitions to appear..."
while [ ! -e "/dev/disk/by-partlabel/$MAIN_LABEL" ] ; do
  sleep 1
  printf '%s' '.'
done
echo

echo "Partitioning complete"

echo "Creating ZFS pool $MAIN_LABEL on /dev/disk/by-partlabel/$MAIN_LABEL"

# setup main partition with zfs
if ! $ZPOOL create -f \
    -o autoexpand=on \
    -o autoreplace=on \
    -o autotrim=on \
    -O aclinherit=passthrough \
    -O aclmode=passthrough \
    -O acltype=posix \
    -O atime=off \
    -O canmount=noauto \
    -O compression=off \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    "$MAIN_LABEL" "/dev/disk/by-partlabel/$MAIN_LABEL"; then
    echo "Creating ZFS pool failed" >&2
    exit 2
fi

echo "Creating ZFS datasets"

if ! $ZFS create -o compression=on "$MAIN_LABEL/$ZFS_NIX" ||
    ! $ZFS create -o compression=on "$MAIN_LABEL/$ZFS_HOME" ||
    ! $ZFS create -o compression=on "$MAIN_LABEL/$ZFS_HARDSTATE" ||
    ! $ZFS create -o compression=on "$MAIN_LABEL/$ZFS_SOFTSTATE"; then
    echo "Creating ZFS datasets failed" >&2
    exit 3
fi
