#!/bin/bash

##### Please note this script is still under development
##### Внимание! Скрипт в стадии разработки и тестирования
##### inspired by mo5 (https://t.me/Ogmins, https://telegra.ph/kliperscreen-04-08 )

##### This script should be installed AFTER install.sh

die() { echo "$*" 1>&2 ; exit 1; }

SCRIPT=$(realpath "$0")
SPATH=$(dirname "$SCRIPT")

echo "Check kernel architecture..."
UN=`uname -a`

#armbian, https://www.armbian.com/orangepi3-lts/
echo "$UN" | grep sunxi64 && LHEADERS=linux-headers-current-sunxi64
echo "$UN" | grep sunxi64 && OVL=armbian-add-overlay

#debian, https://github.com/silver-alx/sbc/releases
echo "$UN" | grep sun50iw6 && LHEADERS=linux-headers-next-sun50iw6
echo "$UN" | grep sun50iw6 && OVL=orangepi-add-overlay
#workaround for kernel 5.10.76
echo "$UN" | grep 5.10.76-sun50iw6 && LHEADERS=linux-headers-current-sun50iw6

[ ! -z "$LHEADERS" ] || die "Unknown kernel architecture"

cd $SPATH

echo "Installing overlay..."
cp $SPATH/dts/sun50i-h6-st7796s-landscape.dts /tmp/sun50i-h6-st7796s.dts 
sudo $OVL /tmp/sun50i-h6-st7796s.dts || die "Error installing overlay"


echo "Copying xorg.conf rules..."
sudo systemctl stop KlipperScreen.service
sudo rm /etc/X11/xorg.conf.d/51*
sudo rm /etc/X11/xorg.conf.d/52*
sudo cp $SPATH/X11/xorg.conf.d/52* /etc/X11/xorg.conf.d

echo "Your need reboot your SBC to activate module"
