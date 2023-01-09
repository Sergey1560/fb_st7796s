#!/bin/bash

##### Please note this script is still under development
##### Внимание! Скрипт в стадии разработки и тестирования

SOURCES="https://github.com/evgs/fb_st7796s.git"

die() { echo "$*" 1>&2 ; exit 1; }

SCRIPT=$(realpath "$0")
SPATH=$(dirname "$SCRIPT")

echo "Check kernel architecture..."
UN=`uname -a`

#armbian
echo "$UN" | grep sunxi64 && LHEADERS=linux-headers-current-sunxi64
echo "$UN" | grep sunxi64 && OVL=armbian-add-overlay

#debian
echo "$UN" | grep sun50iw6 && LHEADERS=linux-headers-next-sun50iw6
echo "$UN" | grep sunxi64 && OVL=orangepi-add-overlay

[ ! -z "$LHEADERS" ] || die "Unknown kernel architecture"

sudo apt update
sudo apt install git build-essential $LHEADERS || die "Error while installing packages"

cd $SPATH

#echo "Fetching sources..."
#git clone $SOURCES || die "Error while fetching sources from github"
cd $SPATH/kernel_module/

echo "Building driver..."
make  || die "Driver compiling fault"

echo "Installing kernel module..."
sudo make install
make clean
sudo depmod -A

echo "Appending to initramfs..."

grep -qxF 'fb_st7796s' /etc/initramfs-tools/modules || echo fb_st7796s | sudo tee /etc/initramfs-tools/modules
sudo update-initramfs -u || die "Error updating initramfs"

echo "Installing overlay..."
sudo $OVL $SPATH/dts/sun50i-h6-st7796s.dts || die "Error installing overlay"

sudo systemctl stop KlipperScreen.service
sudo rm /etc/X11/xorg.conf.d/50-fbturbo.conf
sudo apt remove xserver-xorg-video-fbturbo
sudo apt install xserver-xorg-video-fbdev

echo "Copying xorg.conf rules..."
sudo cp $SPATH/X11/xorg.conf.d/50* /etc/X11/xorg.conf.d
sudo cp $SPATH/X11/xorg.conf.d/51* /etc/X11/xorg.conf.d
sudo cp $SPATH/X11/Xwrapper.conf /etc/X11/

echo "Your need reboot your SBC to activate module"
