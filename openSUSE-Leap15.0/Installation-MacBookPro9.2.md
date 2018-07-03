# openSUSE Leap 15.0 installation guide - MacBook Pro 9.2

The objective of this guide is to make an installation of a minimal openSUSE system on a MacBook Pro 9.2. The installation will have the following characteristics:

- macOS is installed and booted by default;
- openSUSE can be booted by pressing and holding `alt` after turning on the computer, and
- neither [rEFIt](http://refit.sourceforge.net/) nor [rEFInd](http://www.rodsbooks.com/refind/) are used.

In this guide, an installation of a minimal openSUSE system means that the packages to install are those required to boot the system and those that are requested by the user. The idea is to perform an *à la* [ArchLinux](https://www.archlinux.org/) installation. However, the procedure for making openSUSE bootable by pressing and holding `alt` is applicable for any kind of installation.

It will be assumed that

- macOS is already installed;
- openSUSE will be installed in EFI mode;
- the EFI partition that will be used to install openSUSE is different to the EFI partition used by macOS, and
- a bootable USB stick with the "Network Image" is used for the installation.


## Partition scheme

According to \[1\], MacBook's native EFI bootloader looks for `.efi` files inside all the partitions in internal and external drives and shows them as possible boot options if certain conditions are satisfied. Particularly, MacBooks can detect an existing macOS installation after checking that:

* there is a partition formatted as HFS+;
* the partition contains the partition id `af00`;
* in the root of that partition, there is a file called `mach_kernel`, and
* inside that partition, there is a `boot.efi` file inside `/System/Library/CoreServices`.

Also, according to \[1\], it is possible to perform the installation with the already existing EFI partition used by macOS, but that is out of the scope of this guide.

Given the conditions above, the following partitions will be used for the openSUSE installation:

  Partition | Mount point | Type | Comments
  --------- | ----------- | ---- | --------
  /dev/sd*Ni* | /boot/EFI | EFI partition | EFI partition to be used for openSUSE
  /dev/sd*Nj* | / | ext4 | root partition
  /dev/sd*Nk* | /home | ext4 | home partition
  /dev/sd*Nl* | swap | swap | swap partition (non solid-state drives)

where *N* refers to some storage device and *i,j,k,l* refer to some partition numbers. In theory, these partions need not be all in the same device. Many different disk and partition scenarios can exist, but those which have been tested successfully are listed below.

### SSD1 + HDD1

* SSD1 (`sda`)

  This drive is not used for installing openSUSE. The EFI partition used by macOS is in this drive.

* HDD1 (`sdb`)

  Partition | Mount point | Type
  --------- | ----------- | ----
  ... | ... | ...
  /dev/sdb*i* | /boot/EFI | EFI partition
  /dev/sdb*j* | / | ext4
  /dev/sdb*k* | /home | ext4
  /dev/sdb*l* | swap | swap
  ... | ... | ...

### SDD1 + SDD2

* SSD1 (`sda`)

  This drive is not used for installing openSUSE. The EFI partition used by macOS is in this drive.

* SSD2 (`sdb`)

  Partition | Mount point | Type
  --------- | ----------- | ----
  ... | ... | ...
  /dev/sdb*i* | /boot/EFI | EFI partition
  /dev/sdb*j* | / | ext4
  /dev/sdb*k* | /home | ext4
  ... | ... | ...


## Installation procedure

### General installation procedure

1. Power on the computer and boot from the installation USB.

2. Select "Install".

3. Set language and keyboard layout.

4. When setting the user interface, first update the online repositories by clicking "Configure Online Repositories" and selecting

   * "Main Repository (OSS)",
   * "Main Update Repository",
   * "Main Repository (Non-OSS)" and
   * "Main Update Repository (Non-OSS)".

   Then select any user interface. The packages to install will be selected right before starting the actual instalaltion.

4. Set the partition scheme following what is described in the previous section. Particularly, an EFI System Partition must be present in the partition scheme.

5. Set clock and time zone.

7. Create users.

8. In the "Installation Settings" screen, disable the firewall and click "Software" to install the packages in [Installation-Packages.md](Installation-Packages.md).

9. Confirm and start the installation.

When the installation finishes, the computer should restart and boot openSUSE. If that is not the case, the instructions in \[2\] or \[3\] might be helpful to boot into the new system.

### Make openSUSE appear on MacBook's boot manager

1. Install the required utilities for HFS+ filesystem

   ```
   sudo zypper ar -f http://download.opensuse.org/repositories/home:/malcolmlewis:/openSUSE_General/openSUSE_Leap_15.0/ MalcolmLewis
   sudo zypper refresh
   sudo zypper install diskdev_cmds
   ```

2. Find out the disk where the EFI partition for openSUSE is

   ```
   sudo fdisk -l
   ```

   It will be assumed that the disk is `/dev/sdN`, where *N* is determined by the output of `fdisk -l`.

3. Update the EFI partition

   ```
   sudo gdisk /dev/sdN
   ```

   Execute `p` and look for the partition number *i* of the EFI partition for openSUSE.

   Execute `d` and specify the previous partition number *i*.

   Execute `n` and set the same partition number *i*. For first sector and last sector set the same values that this partition currently has. Finally, set `AF00` as the filesystem code.

   Execute `w`.

4. Find out the current partition mounted on `/boot/efi`

   ```
   mount | grep /boot/efi
   ```

   and unmount it

   ```
   sudo umount /dev/sdXY
   ```

   where *X* and *Y* are determined by the output of `mount | grep /boot/efi`.

5. Format the new EFI partition

   ```
   sudo mkfs.hfsplus /dev/sdNi -v openSUSE
   ```

   where *N* and *i* are the same values from step 3.

6. Open `/etc/fstab` and delete the line that refers to `/boot/efi`, save and close the file. Then execute

   ```
   sudo bash -c 'echo UUID=$(blkid -o value -s UUID /dev/sdNi) /boot/efi auto defaults 0 0 >> /etc/fstab'
   ```

   where *N* and *i* are the same values from step 3.

7. Mount the new EFI partition

   ```
   sudo mount /boot/efi
   ```

8. Re-install grub on the new EFI partition

   ```
   sudo mkdir -p /boot/efi/EFI/opensuse/
   sudo touch /boot/efi/EFI/opensuse/mach_kernel
   sudo grub2-install --target x86_64-efi --boot-directory=/boot --efi-directory=/boot/efi --bootloader-id="opensuse"
   sudo sed -i 's/GRUB_HIDDEN/#GRUB_HIDDEN/g' /etc/default/grub
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
   ```

   Open `/boot/efi/EFI/opensuse/System/Library/CoreServices/SystemVersion.plist` and modify the *ProductVersion* string value to `15.0`.

9. Make MacBook's boot manager recognize the openSUSE installation

   ```
   sudo mkdir -p /boot/efi/System/Library/CoreServices
   sudo touch /boot/efi/mach_kernel
   sudo ln /boot/efi/EFI/opensuse/System/Library/CoreServices/boot.efi /boot/efi/System/Library/CoreServices/boot.efi
   sudo cp /boot/efi/EFI/opensuse/System/Library/CoreServices/SystemVersion.plist /boot/efi/System/Library/CoreServices/
   ```

10. In order for a custom icon to appear on the MacBook Pro boot manager, copy a `.icns` file

    ```
    sudo cp <file.icns> /boot/efi/.VolumeIcon.icns
    ```

11. To prevent macOS from automatically mounting the openSUSE EFI partition, boot into macOS and execute

    ```
    diskutil info /Volumes/openSUSE | grep "Volume UUID" | awk 'NF>1{print $NF}'
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
