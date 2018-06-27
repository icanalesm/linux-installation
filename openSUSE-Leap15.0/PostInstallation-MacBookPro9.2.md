# openSUSE Leap 15.0 post-installation guide - MacBook Pro (9.2)

The objective of this guide is to configure a minimal openSUSE system installation on MacBook Por 9.2 as described in [Installation-MacBookPro9.2.md](Installation-MacBookPro9.2.md).


## Post installation

Follow the "Post installation" section of [PostInstallation.md](PostInstallation.md) and the procedure described in this document. When one of the following subsections appears in both, here and PostInstallation.md, the instructions in this document take precedence.

### X Window System

```
sudo zypper install --no-recommends xorg-x11-server xorg-x11-fonts xf86-video-intel xf86-input-libinput xinit
```

In order to execute X without a display manager, open `/etc/permissions.local` and uncomment the line

```
/usr/bin/Xorg  root:root  4711
```

then execute

```
sudo chkstat --system --set
```

Optionally, configure keyboard for X

```
sudo localectl --no-convert set-x11-keymap <layout> apple_laptop mac
```

where *<layout>* is one of the available layouts from

```
localectl list-x11-keymap-layouts
```
### Wi-Fi

Install either the wl-driver (option 1) or firmware for b43 driver (option 2)

* Option 1 (Recommended)

  Install broadcom-wl wireless driver for Broadcom 4331 from [Packman](http://packman.links2linux.org/)

  ```
  sudo zypper ar -f http://packman.inode.at/suse/openSUSE_Leap_15.0/ Packman
  sudo zypper refresh
  sudo zypper install broadcom-wl broadcom-wl-kmp-default
  ```

* Option 2

  Install firmware for b43 wireless driver

  ```
  sudo zypper install --no-recommends b43-fwcutter
  sudo install_bcm43xx_firmware
  ```

Install NetworkManager and the network yast module

```
sudo zypper install --no-recommends NetworkManager yast2-network
```

Execute `yast` and under "System" select "Network Settings". In the "Global Options" tab set "NetworkManager Service" as Network Setup Method.

Execute `nmtui` to manage network connections.
