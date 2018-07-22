# openSUSE Leap 15.0 post-installation guide - MacBook Pro 9.2

The objective of this guide is to configure a minimal openSUSE system installation on a MacBook Pro 9.2 as described in [Installation-MacBookPro9.2.md](Installation-MacBookPro9.2.md).


## Post installation

### Network manager

#### NetworkManager

```
sudo zypper install --no-recommends NetworkManager yast2-network
```

Execute `yast` and under "System" select "Network Settings". In the "Global Options" tab set "NetworkManager Service" as Network Setup Method.

### Firewall

#### firewalld

`firewalld` should be installed by default. If that is not the case

```
sudo zypper install --no-recommends firewalld
```

### Wi-Fi

#### Broadcom 4331

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

### NTP

#### chrony

```
sudo zypper install --no-recommends chrony
```

`systemd-timesyncd.service` is in conflict with `chronyd.service`, so disable it first

```
sudo systemctl disable systemd-timesyncd.service
```

and then enable `chronyd.service`

```
sudo systemctl enable chronyd.service
```

Enable NetworkManager's dispatcher to inform chrony when the network status has changed

```
sudo systemctl enable NetworkManager-dispatcher.service
```

### Power management

#### TLP

```
sudo zypper install tlp
```

Enable services required by `tlp` and mask `rfkill` service and socket to avoid conflicts

```
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

### Fonts

#### Arimo, Cousine, Tinos

```
sudo zypper install --no-recommends google-arimo-fonts google-cousine-fonts google-tinos-fonts
```

#### Font Awesome

```
...
```

#### Inconsolata

```
sudo zypper install --no-recommends google-inconsolata-fonts
```

#### Open Sans

```
sudo zypper install --no-recommends google-opensans-fonts
```


### X Window System

```
sudo zypper install --no-recommends xorg-x11-server xf86-input-libinput xf86-video-intel xinit
```

In order to execute X without a display manager, open `/etc/permissions.local` and uncomment the line

```
/usr/bin/Xorg  root:root  4711
```

then execute

```
sudo chkstat --system --set
```

Optionally, configure the keyboard for X

```
sudo localectl --no-convert set-x11-keymap <layout> apple_laptop mac
```

where *\<layout\>* is one of the available layouts from

```
localectl list-x11-keymap-layouts
```

### Window manager

#### dwm

If required, install the required library dependencies

```
sudo zypper install --no-recommends libX11-devel libXft-devel libXinerama-devel
```

Download [dwm](https://dwm.suckless.org/), apply the desired customisations and patches.

Compile and install

```
make
sudo make install
```

To execute `dwm`, add `exec dwm` in a new line at the end of `~/.xinitrc` and execute `startx`.

My customised version of dwm: [github.com/icanalesm/dwm](https://github.com/icanalesm/dwm).

My customised version of [slstatus](https://tools.suckless.org/slstatus): [github.com/icanalesm/slstatus](https://github.com/icanalesm/slstatus).

### Terminal emulator

#### rxvt-unicode

```
sudo zypper install --no-recommends rxvt-unicode
```

### Color calibration

```
sudo zypper install --no-recommends xcalib
```

### Backlight control

```
git clone https://github.com/icanalesm/brightctl.git
cd brightctl
```

Apply the desired configuration.

Compile and install

```
make
sudo make install
```

To configure `sudo` to allow user *\<user\>* to execute `brightctl` as *root* without the password, execute

```
sudo visudo -f /etc/sudoers.d/brightness
```

and add the following line

```
<user> ALL=NOPASSWD:/usr/local/bin/brightctl
```

### Sound

```
sudo zypper install --no-recommends alsa alsa-utils alsa-plugins
```

Execute `alsamixer` to adjust the required playback controls.

### Web browser

```
sudo zypper install --no-recommends MozillaFirefox
```

### Keyboard

#### Use function keys by default

If the `F<num>` keys do not work, this is probably because the kernel driver for the keyboard has defaulted to using the media keys, thus it is required to use the `Fn` key to get the `F<num>` keys. To change this behaviour, set the `hid_apple fnmode` option to `2` in file `/etc/modprobe.d/hid_apple.conf`

```
options hid_apple fnmode=2
```

