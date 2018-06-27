# openSUSE Leap 15.0 installation guide

The objective of this guide is to make an installation of a minimal openSUSE system.

It will be assumed that

- openSUSE will be installed in EFI mode, and
- a bootable USB stick with the "Network Image" is used for the installation.


## General installation procedure

1. Power on the computer and boot from the installation USB.

2. Select "Install".

3. Set language and keyboard layout.

4. When setting the user interface, first update the online repositories by clicking "Configure Online Repositories" and selecting

   * "Main Repository (OSS)",
   * "Main Update Repository",
   * "Main Repository (Non-OSS)" and
   * "Main Update Repository (Non-OSS)",

   then select "Custom" to manually choose the packages to install (see next section).

4. Set partition scheme. An EFI System Partition must be present in the partition scheme.

5. Set clock and time zone.

7. Create users.

8. Confirm and start the installation.


## Minimal installation

When choosing the user interface, select "Custom" to get to "Software Selection and System Tasks", then click "Details" for selecting individual packages.

For a bootable extremely minimal installation, select the following packages:

- aaa_base
- chrony
- dosfstools
- firewalld
- grub2-x86_64-efi
- kernel-default
- kexec-tools
- mokutil
- shim

The following are useful packages and installing them will keep the system minimal:

- bash_doc
- ca-certificates
- ca-certificates-mozilla
- command-not-found
- gcc
- gettext-runtime
- git
- gptfdisk
- hdparm
- iproute2
- iputils
- less
- logrotate
- m4
- make
- man
- man-pages
- ntp
- pciutils
- pcmciautils
- perl
- psmisc
- screen
- sensors
- sudo
- tar
- unzip
- unzip-doc
- usbutils
- vim
- vim-data
- wget
- wpa_supplicant
- yast2
