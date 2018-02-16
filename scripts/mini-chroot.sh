#!/bin/bash

MIRROR=http://dl-cdn.alpinelinux.org/alpine
ARCH=x86_64
CHROOT=alpine
VERSION=v3.7
APK_TOOL=apk-tools-static-2.8.2-r0.apk
DEVICE=$1

set -o xtrace

function print_usage {
    echo "USAGE:
    $0 <INSTALL_DEVICE>
        INSTALL_DEVICE Install alpine on this device"
}

function init {
    if [ -z "$DEVICE" ]
    then
        print_usage
        exit 1
    fi

    if [ "$SHELL" != "/bin/bash" ]
    then
        echo "Use bash to launch script"
        #exit 1
    fi
}

function debug {
  echo "==> $1"
}

function check_uid {
  debug "Check UID"
  ROOT_UID=0
  if [ "$UID" -ne "$ROOT_UID" ]
  then
      echo "You are not root. Please use su to become root."
      exit 0
  fi
}

function create_chroot_dir {
  debug "Create chroot directory"
  if [ -d "$CHROOT" ]
  then
      echo "$CHROOT already exists."
  else
      mkdir -p $CHROOT
  fi
}

function download_apk_tool {
  debug "Download apk tools"
  wget $MIRROR/$VERSION/main/$ARCH/$APK_TOOL
  tar -xzf $APK_TOOL
}

function install_chroot {
  debug "Install alpine in chroot"
  ./sbin/apk.static \
      -X $MIRROR/$VERSION/main \
      -U \
      --allow-untrusted \
      --root ./$CHROOT \
      --initdb add alpine-base alpine-sdk
}

function create_fs_arbo {
    debug "Create fs tree"
    mkdir -p $CHROOT{/root,/etc/apk,/proc}
}

function mount_bind {
  debug "Mount bind"
  mount --bind /proc $CHROOT/proc
  mount --bind /dev $CHROOT/dev
}

function setup_repository {
    debug "Setup alpine repository"
    echo "$MIRROR/$VERSION/main" >  $CHROOT/etc/apk/repositories
}

function setup_resolv_conf {
    debug "Setup resolve.conf"
    cp /etc/resolv.conf $CHROOT/etc/
}

function cleanup_tools {
  debug "Cleanup tools"
  rm -rf sbin
  rm -f $APK_TOOL
}

function Main {
    init
    check_uid
    create_chroot_dir
    download_apk_tool
    install_chroot
    create_fs_arbo
    mount_bind
    setup_repository
    setup_resolv_conf
    cleanup_tools
}

Main
