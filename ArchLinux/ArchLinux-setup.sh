#!/bin/sh

# Installation and configuration script for a new system installation. This script must be executed after changing root
# into the new system. It is assumed that before changing root,
#
# - the installation consists of the packages base, linux, linux-firmware,
# - the fstab file has been generated.
#
# After executing this script, the following installation and configuration tasks must be done:
#
# - Install and configure bootloader
# - Set kernel parameters
# - Unlock home partition at boot
# - Update mount options in /etc/fstab
# - Configure chrony, TLP
# - Configure sudo for privilege elevation
# - Create unprivileged user
# - Configure kernel modules through files in /etc/modprobe.d/

region=Europe
city=Oslo
locale_name=en_GB.UTF-8
locale_charset=UTF-8
locale_langs=en_GB
vconsole_keymap=es
vconsole_font=Lat2-Terminus16
hostname=jupiterx
microcode_pkg=intel-ucode

ln -sf "/usr/share/zoneinfo/$region/$city" /etc/localtime
hwclock --systohc
sed -i "s/^#$locale_name $locale_charset/$locale_name $locale_charset/" /etc/locale.gen
locale-gen
printf "LANG=%s\nLANGUAGE=%s" "$locale_name" "$locale_langs" > /etc/locale.conf
printf "KEYMAP=%s\nFONT=%s" "$vconsole_keymap" "$vconsole_font" > /etc/vconsole.conf
printf "%s" "$hostname" > /etc/hostname
printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t%s" "$hostname" >> /etc/hosts
printf "Set root password\n"
passwd

pacman -S base-devel e2fsprogs dosfstools man-db man-pages unzip vim tmux rsync wget git openssh

# Microcode

pacman -S "$microcode_pkg"

# Network

pacman -S networkmanager
systemctl enable NetworkManager.service
systemctl enable NetworkManager-dispatcher.service

# Firewall

pacman -S firewalld
systemctl enable firewalld.service

# NTP

pacman -S chrony
systemctl disable systemd-timesyncd.service
systemctl enable chronyd.service

# Power management

pacman -S ethtool smartmontools tlp tlp-rdw
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable tlp.service

# Fonts

pacman -S ttf-ibm-plex ttf-fira-mono ttf-font-awesome

# X Window System

pacman -S xorg-server xorg-xinit xorg-xrandr
printf "Section \"InputClass\"\n\tIdentifier \"libinput touchpad catchall\"\n\tMatchIsTouchpad \"on\"\n\tMatchDevicePath \"/dev/input/event*\"\n\tDriver \"libinput\"\n\tOption \"Tapping\" \"On\"\nEndSection" >> /etc/X11/xorg.conf.d/40-libinput.conf

# Screen colour temperature and monitor colour calibration

pacman -S redshift xcalib

# Sound

pacman -S pipewire pipewire-alsa pipewire-pulse pavucontrol

# Desktop notifications

pacman -S libnotify dunst

# Web browser

pacman -S firefox

# Document viewer

pacman -S zathura zathura-pdf-mupdf zathura-ps zathura-djvu

# gvim

pacman -S gvim

# mkinitcpio configuration

sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux
