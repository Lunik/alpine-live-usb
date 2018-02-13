#!/bin/bash

MIRROR=http://dl-cdn.alpinelinux.org/alpine
ARCH=x86_64
CHROOT=alpine
VERSION=v3.7
APK_TOOL=apk-tools-static-2.8.2-r0.apk

# Root has $UID 0
ROOT_UID=0
if [ "$UID" != "$ROOT_UID" ]
then
    echo "You are not root. Please use su to become root."
fi

if [ -d $CHROOT ]
then
    echo "$CHROOT already exists."
else
    mkdir -p $CHROOT
fi

wget $MIRROR/$VERSION/main/$ARCH/$APK_TOOL
tar -xzf $APK_TOOL
./sbin/apk.static \
    -X $MIRROR/$VERSION/main \
    -U \
    --allow-untrusted \
    --root ././$CHROOT \
    --initdb add alpine-base alpine-sdk

mkdir -p $CHROOT{/root,/etc/apk,/proc}

mount --bind /proc $CHROOT/proc

mknod -m 666 $CHROOT/dev/full c 1 7
mknod -m 666 $CHROOT/dev/ptmx c 5 2
mknod -m 644 $CHROOT/dev/random c 1 8
mknod -m 644 $CHROOT/dev/urandom c 1 9
mknod -m 666 $CHROOT/dev/zero c 1 5
mknod -m 666 $CHROOT/dev/tty c 5 0
rm -f $CHROOT/dev/null
mknod -m 666 $CHROOT/dev/null c 1 3

cp /etc/resolv.conf $CHROOT/etc/
echo "$MIRROR/$VERSION/main" >  $CHROOT/etc/apk/repositories

# Cleaning up
rm -rf sbin
rm -f $APK_TOOL

echo "\
    Your Alpine Linux installation in '$CHROOT' is ready now.\
    To start Alpine:\
    sudo chroot $CHROOT /bin/sh -l\
"
