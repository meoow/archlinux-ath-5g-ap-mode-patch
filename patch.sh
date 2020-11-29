#!/bin/bash - 
#============================================================================
#
#          FILE: patch.sh
# 
#         USAGE: ./patch.sh 
# 
#   DESCRIPTION: Patch and compile kernel module ath for enabling AP mode
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Meow 
#  ORGANIZATION: 
#       CREATED: 07/27/2020 03:09
#      REVISION:  ---
#============================================================================

set -o nounset                        # Treat unset variables as an error


export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=linux-lts
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"
export pkgbase=linux-lts
export pkgver=$(uname -r|(IFS=- read x _ _;echo $x))
export pkgrel=$(uname -r|(IFS=- read _ x _;echo $x))
export pkgdesc='LTS Linux'
export _srcname=linux-$pkgver

wget http://mirrors.ustc.edu.cn/kernel.org/linux/kernel/v${pkgver%%.*}.x/${_srcname}.tar.xz

rm -rf linux-$pkgver
tar Jxf linux-$pkgver.tar.xz

cd linux-$pkgver

scripts/setlocalversion --save-scmversion
echo "-$pkgrel" > localversion.10-pkgrel
echo "${pkgbase#linux}" > localversion.20-pkgname

patch -Np1 < ../ath_5g_ap.patch

make clean
make mrproper
cp /usr/lib/modules/$(uname -r)/build/Module.symvers ./
zcat /proc/config.gz > .config
yes y | make oldconfig
make prepare
make scripts
make M=drivers/net/wireless/ath -j4
xz drivers/net/wireless/ath/ath.ko
sudo cp -f drivers/net/wireless/ath/ath.ko.xz /lib/modules/$(uname -r)/kernel/drivers/net/wireless/ath/ath.ko.xz
sudo depmod -a
