# ArchLinux installation guide - MacBook Pro 9.2

This guide shows how to perform an installation of ArchLinux on a MacBook Pro 9.2, such that:

- macOS is installed and booted by default;
- ArchLinux can be booted by pressing and holding `alt` after turning on the computer, and
- neither [rEFIt](http://refit.sourceforge.net/) nor [rEFInd](http://www.rodsbooks.com/refind/) are used.

The installation will be a minimal one, meaning that the packages to install are those required to boot the system and those requested by the user only.

The procedure for making openSUSE bootable on a MacBook Pro 9.2 by pressing and holding `alt` is independent of the minimal installation, i.e. the procedure is applicable to any ArchLinux installation.

It will be assumed that

- macOS is already installed;
- ArchLinux will be installed in EFI mode;
- the EFI partition that will be used to install ArchLinux is different to the EFI partition used by macOS, and
- an [Arch Linux Installer USB](https://wiki.archlinux.org/index.php/USB_flash_installation_media) is used for the installation.


## Partition scheme

According to \[1\], MacBook's native EFI bootloader looks for `.efi` files inside all the partitions in internal and external drives and shows them as possible boot options if certain conditions are satisfied. Particularly, MacBooks can detect an existing macOS installation after checking that:

* there is a partition formatted as HFS+;
* the partition contains the partition id `af00`;
* in the root of that partition, there is a file called `mach_kernel`, and
* inside that partition, there is a `boot.efi` file inside `/System/Library/CoreServices`.

Also, according to \[1\], it is possible to perform the installation with the already existing EFI partition used by macOS, but that is out of the scope of this guide.

Given the conditions above, the following partitions must be exist for the ArchLinux installation:

  Partition | Mount point | Type | Comments
  --------- | ----------- | ---- | --------
  /dev/sd*Ni* | /boot/EFI | EFI partition | EFI partition to be used for ArchLinux
  /dev/sd*Nj* | / | ext4 | root partition
  /dev/sd*Nk* | /home | ext4 | home partition
  /dev/sd*Nl* | swap | swap | swap partition (non solid-state drives)

where *N* refers to some storage device and *i,j,k,l* refer to some partition numbers. In theory, these partions need not be all in the same device. Many different disk and partition scenarios can exist, but those which have been tested successfully are listed below.

### SDD1 + SDD2

* SSD1 (`sda`)

  This drive is not used for installing ArchLinux. The EFI partition used by macOS is in this drive.

* SSD2 (`sdb`)

  Partition | Mount point | Type
  --------- | ----------- | ----
  ... | ... | ...
  /dev/sdb*i* | /boot/EFI | EFI partition
  /dev/sdb*j* | / | ext4
  /dev/sdb*k* | /home | ext4
  ... | ... | ...


## Installation procedure

[ArchWiki](https://wiki.archlinux.org/) has a detailed entry on [installing ArchLinux](https://wiki.archlinux.org/index.php/Installation_guide) and another one on [installing ArchLinux on a Mac](https://wiki.archlinux.org/index.php/mac). The instructions in this guide are heavily based on those articles. Given the rolling release nature of ArchLinux, when some of the instructions here are no longer working, checking the previous entries in ArchWiki is the way to go.

### Pre-installation

Power on the computer and boot from the installation USB.

#### Set keyboard layout

```
loadkeys <map>
```

where *<map>* is one of the available layouts from

```
ls /usr/share/kbd/keymaps/**/*.map.gz
```

omitting path and file extension.

#### Connect to the Internet

Verify that there is a working Internet connection

```
ping archlinux.org
```

If no connection is available, stop the dhcpcd service with `systemctl stop dhcpcd@<interface>` where *<interface>* can be tab-completed. Then configure the network as described in [ArchWiki's Network configuration](https://wiki.archlinux.org/index.php/Network_configuration).

#### Update the system clock

```
timedatectl set-ntp true
```

#### Partition the disks

Set the partition scheme following what is described in the "Partition scheme" section of this guide.

#### Format the partitions

The installation environment does not include the tools required for formatting the EFI partion as HFS+, so it will be temporarily formatted as FAT

```
mkfs.vfat /dev/sdNi
mkfs.ext4 /dev/sdNj
mkfs.ext4 /dev/sdNk
```

where *N* refers to the storage device in which the partitions are and *i,j,k* refer to the EFI, root and home partition numbers respectively.

If a swap partition `/dev/sdNl` (`l` is letter '*l*' not number *1*) was created, initialize it with `mkswap` 

```
mkswap /dev/sdNl
swapon /dev/sdNl
```

#### Mount the file systems

Mount the root partition under `/mnt`, and the EFI and home partitions under the root partition

```
mount /dev/sdNj /mnt
mkdir -p /mnt/boot/efi
mount /dev/sdNi /mnt/boot/efi
mkdir /mnt/home
mount /dev/sdNk /mnt/home
```

where *N* refers to the storage device in which the partitions are and *i,j,k* refer to the EFI, root and home partition numbers respectively.

### Installation

#### Select the mirrors

Packages to be installed must be downloaded from mirror servers, which are defined in `/etc/pacman.d/mirrorlist`. On the installation system, all mirrors are enabled, and sorted by their synchronization status and speed at the time the installation image was created.

The higher a mirror is placed in the list, the more priority it is given when downloading a package. It is advisable to edit the file accordingly, and move the geographically closest mirrors to the top of the list (although other criteria should be taken into account).

This file will later be copied to the new system by `pacstrap`, so it is worth getting right.

#### Install initial package groups

```
pacstrap /mnt base base-devel
```

#### Generate `/etc/fstab` file

```
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Change root into the new system

```
arch-chroot /mnt
```

#### Manage packages

Remove packages from **base** and **base-devel** according to [Installation-Packages.md](Installation-Packages.md)

```
pacman -Rs <package_1> ... <package_n>
```

Install additional packages according to [Installation-Packages.md](Installation-Packages.md)

```
pacman -Syu <package_1> ... <package_n>
```

#### Time zone

```
ln -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime
```

where *<Region>* and *<City>* can be checked by executing `ls` in the `/usr/share/zoneinfo` and `/usr/share/zoneinfo/<Region>` directories, respectively. Then, generate `/etc/adjtime`

```
hwclock --systohc
```

#### Locale

Open file `/etc/locale.gen`, uncomment the desired localisation(s), and generate them with

```
locale-gen
```

Create file `/etc/locale.conf` and add lines setting the variables [`LANG`](http://www.gnu.org/software/gettext/manual/gettext.html#Locale-Names) and [`LANGUAGE`](http://www.gnu.org/software/gettext/manual/gettext.html#The-LANGUAGE-variable) to the desired values

```
LANG=<localisation>
LANGUAGE=<list_languages>
```

Make keyboard layout persistent by creating file `/etc/vconsole.conf` and adding a line setting variable `KEYMAP` to the desired layout (view "Set keyboard layout" above)

```
KEYMAP=<map>
```

#### Network configuration

Create file `/etc/hostname` and add a line with the desired hostname *<hostname>*

```
<hostname>
```


Create file `/etc/hosts` and add matching entries

```
127.0.0.1    localhost
127.0.1.1    <hostname>.localdomain    <hostname>
::1          localhost
```

If the system has a permanent IP address, it should be used instead of `127.0.1.1`.

Complete the network configuration for the newly installed environment as described in [ArchWiki's Network configuration](https://wiki.archlinux.org/index.php/Network_configuration). Finally, verify that there is a working Internet connection

```
ping archlinux.org
```

#### Set root password

```
passwd
```

#### Make ArchLinux appear on MacBook's boot manager

Create a user for building and installing the **hfsprogs** package from [AUR](https://aur.archlinux.org/)

```
useradd --create-home <user>
passwd <user>
```

and switch user

```
su <user>
cd ~
```

Install the required utilities for HFS+ filesystem

**WARNING**: As stated in [ArchWiki's AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository):
> *Carefully check all files*. Carefully check the `PKGBUILD` and any .install file for malicious commands. `PKGBUILD`s are bash scripts containing functions to be executed by `makepkg`: these functions can contain any valid commands or Bash syntax, so it is totally possible for a `PKGBUILD` to contain dangerous commands through malice or ignorance on the part of the author. Since `makepkg` uses `fakeroot` (and should never be run as root), there is some level of protection but you should never count on it. If in doubt, do not build the package and seek advice on the forums or mailing list.

```
git clone https://aur.archlinux.org/hfsprogs.git
cd hfsprogs
makepg -si
```

Switch back to *root* user by executing `exit` or pressing `Ctrl+D`.

Find out the disk where the EFI partition for ArchLinux is

```
fdisk -l
```

It will be assumed that the disk is `/dev/sdN`, where *N* is determined by the output of `fdisk -l`.

Update the EFI partition

```
gdisk /dev/sdN
```

Execute `p` and look for the partition number *i* of the EFI partition for ArchLinux.

Execute `d` and specify the previous partition number *i*.

Execute `n` and set the same partition number *i*. For first sector and last sector set the same values that this partition currently has. Finally, set `AF00` as the filesystem code.

Execute `w`.

Find out the current partition mounted on `/boot/efi`

```
mount | grep /boot/efi
```

and unmount it

```
umount /dev/sdXY
```

where *X* and *Y* are determined by the output of `mount | grep /boot/efi`.

Format the new EFI partition

```
mkfs.hfsplus /dev/sdNi -v archlinux
```

where *N* and *i* are the same values as above.

Open `/etc/fstab` and delete the line that refers to `/boot/efi`, save and close the file. Then execute

```
bash -c 'echo UUID=$(blkid -o value -s UUID /dev/sdNi) /boot/efi auto defaults 0 0 >> /etc/fstab'
```

where *N* and *i* are the same values from step 3.

Mount the new EFI partition

```
mount /boot/efi
```

Re-install grub on the new EFI partition

```
mkdir -p /boot/efi/EFI/archlinux
touch /boot/efi/EFI/archlinux/mach_kernel
grub-install --target x86_64-efi --boot-directory=/boot --efi-directory=/boot/efi --bootloader-id="archlinux"
grub-mkconfig -o /boot/grub/grub.cfg
```

Open `/boot/efi/EFI/archlinux/System/Library/CoreServices/SystemVersion.plist` and modify the *ProductName* string value to `Linux` and the *ProductVersion* string value to `ArchLinux`.

Make MacBook's boot manager recognize the ArchLinux installation

```
mkdir -p /boot/efi/System/Library/CoreServices
touch /boot/efi/mach_kernel
ln /boot/efi/EFI/archlinux/System/Library/CoreServices/boot.efi /boot/efi/System/Library/CoreServices/boot.efi
cp /boot/efi/EFI/archlinux/System/Library/CoreServices/SystemVersion.plist /boot/efi/System/Library/CoreServices/
```

Create a new `initramfs`

```
mkinitcpio -p linux
```

In order for a custom icon to appear on the MacBook Pro boot manager, copy a `.icns` file

```
cp <file.icns> /boot/efi/.VolumeIcon.icns
```

#### Reboot

Exit the chroot environment by executing `exit` or pressing `Ctrl+D`.

Optionally, unmount all the partitions

```
umount -R /mnt
```

Finally, restart the machine by executing `reboot`.

To prevent macOS from automatically mounting the ArchLinux EFI partition, boot into macOS and execute

```
diskutil info /Volumes/archlinux | grep "Volume UUID" | awk 'NF>1{print $NF}'
```

copy the UUID value, then

```
sudo vifs
```

add `UUID=<copied UUID value> none hfs rw,noauto` in a new line, save and close the file.

## References

\[1\] [Mac - ArchWiki](https://wiki.archlinux.org/index.php/mac)
\[2\] [Ubuntu installation on USB stick with pure EFI boot (Mac compatible)](https://medium.com/@mmiglier/ubuntu-installation-on-usb-stick-with-pure-efi-boot-mac-compatible-469ad33645c9)
\[3\] [Ubuntu + Mac: Pure EFI Boot](http://heeris.id.au/2014/ubuntu-plus-mac-pure-efi-boot)
\[4\] [Debian EFI mode boot on a Macbook Pro, without rEFIt](https://glandium.org/blog/?p=2830)
\[5\] [Managing EFI Boot Loaders for Linux](http://www.rodsbooks.com/efi-bootloaders)
\[6\] [Unified Extensible Firmware Interface - ArchWiki](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface)
