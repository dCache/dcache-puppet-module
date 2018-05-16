#!/bin/bash

# small script for setting up hosts attached to dell powervault MD3XXX storage arrays (MD3260, MD3460)

# Managed by Puppet (dcache::array). Do NOT edit!

set -x
set -e

hostshort=$(hostname -s)
hostsuffix=${hostshort//dcache-/}
ndevices=$(ls /dev/mapper/mpath* | wc -w)

# do some sanity checks...
test -n "$ndevices"
test -n "$hostsuffix"
grep -q "$hostsuffix" /etc/fstab && exit
grep -q "/dcache/" /etc/fstab && exit
mount | grep -q /dcache/ && exit
multipath -l | grep mpath | wc -l | grep -q $ndevices

echo
ls -l /dev/mapper/mpath*
echo

set +x
read -p "The previous $ndevices devices were detected. Do you want to create a new xfs filesystem on this devices? [y|N] " reply
case $reply in
    y|Y) mkfs=yes ;;
    *) read -p "No filesystem will be configured. Press any key to configure /etc/fstab and mount the listed devices (or CTRL+C to exit). " ;;
esac
set -x

if [ "$mkfs" == "yes" ] ; then
    sleep 7
    c=1
    for i in /dev/mapper/mpath* ; do
        j=$(printf '%02d' $c)
        mkfs.xfs -L ${hostsuffix}-$j $i
        let c+=1
    done
fi

for i in $(seq -w 01 ${ndevices}) ; do
    echo "LABEL=${hostsuffix}-${i} /dcache/dcache-${hostsuffix}-${i} xfs defaults,noatime 1 1" >> /etc/fstab
    mkdir -p /dcache/dcache-${hostsuffix}-${i}
    mount /dcache/dcache-${hostsuffix}-${i}
    mkdir -p /dcache/dcache-${hostsuffix}-${i}/{meta,data,control}
done

