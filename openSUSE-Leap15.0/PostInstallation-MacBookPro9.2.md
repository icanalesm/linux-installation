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

```
sudo zypper install --no-recommends firewalld
sudo systemctl unmask firewalld.service
sudo systemctl enable --now firewalld.service
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

`systemd-timesyncd.service` is in conflict with `chronyd.service`, so disable it first:

```
sudo systemctl disable systemd-timesyncd.service
```

and then enable `chronyd.service`:

```
sudo systemctl enable chronyd.service
```

Enable NetworkManager's dispatcher to inform chrony when the network status has changed:

```
sudo systemctl enable NetworkManager-dispatcher.service
```

### Power management

#### TLP

```
sudo zypper install --no-recommends ethtool smartmontools tlp tlp-rdw
```

Enable services required by `tlp` and mask `rfkill` service and socket to avoid conflicts:

```
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

Configure radio devices in `/etc/defualt/tlp`

```
DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
DEVICES_TO_ENABLE_ON_SHUTDOWN="bluetooth"
```

### Power off, reboot, suspend, hibernate

Configure `sudo` to allow user *\<user\>* to execute the necessary *systemctl* system commands as *root* without asking for the password:

```
sudo visudo -f /etc/sudoers.d/usercmds
```

and add the following lines

```
## systemctl system commands
<user> <hostname>=NOPASSWD:/usr/bin/systemctl poweroff,/usr/bin/systemctl reboot,/usr/bin/systemctl suspend,/usr/bin/systemctl hibernate
```

where *\<hostname\>* is the machine's hostname.

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

Optionally, configure the keyboard for X:

```
sudo localectl --no-convert set-x11-keymap <layout> apple_laptop mac
```

where *\<layout\>* is one of the available layouts from

```
localectl list-x11-keymap-layouts
```

### Keyboard and touchpad configuration

#### Tap for touchpad

Add `Option "Tapping" "On"` to the *touchpad* section in file `40-libinput.conf`:

```
...
Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "On"
EndSection
...
```

File `40-libinput.conf` can be in either `/etc/X11/xorg.conf.d/` or `/usr/share/X11/xorg.conf.d/`.

#### Function keys

The behaviour of `fn`+`F<num>` is configured by the `fnmode` option of the `hid_apple` kernel module via the `/etc/modprobe.d/hid_apple.conf` file.

- To disable the `fn` key (`fn`+`F<num>` will behave like `F<num>` only), add the following line:
  ```
  options hid_apple fnmode=0
  ```
- To get `F<num>` by pressing `fn`+`F<num>`, add the following line:
  ```
  options hid_apple fnmode=1
  ```
- To get `F<num>` by pressing `F<num>`, add the following line:
  ```
  options hid_apple fnmode=2
  ```

### Window manager

#### dwm

If required, install the required library dependencies:

```
sudo zypper install --no-recommends libX11-devel libXft-devel libXinerama-devel
```

Download [dwm](https://dwm.suckless.org/), apply the desired customisations and patches.

Compile and install:

```
make
sudo make install
```

To execute `dwm`, add `exec dwm` in a new line at the end of `~/.xinitrc` and execute `startx`.

My customised version of dwm: [github.com/icanalesm/dwm](https://github.com/icanalesm/dwm).

tstat to set the status: [github.com/icanalesm/tstat](https://github.com/icanalesm/tstat).

### Terminal emulator

#### rxvt-unicode

```
sudo zypper install --no-recommends rxvt-unicode
```

### Color calibration

#### xcalib

```
sudo zypper install --no-recommends xcalib
```

### Backlight control

#### brightctl

```
git clone https://github.com/icanalesm/brightctl.git
cd brightctl
```

Apply the desired configuration.

Compile and install:

```
make
sudo make install
```

Configure `sudo` to allow user *\<user\>* to execute `brightctl` as *root* without asking for the password:

```
sudo visudo -f /etc/sudoers.d/usercmds
```

and add the following line

```
## brightctl commands
<user> <hostname>=NOPASSWD:/usr/local/bin/brightctl
```

where *\<hostname\>* is the machine's hostname.

### Sound

```
sudo zypper install --no-recommends alsa alsa-utils alsa-plugins
```

Execute `alsamixer` to adjust the required playback controls.

### Web browser

#### Firefox

```
sudo zypper install --no-recommends MozillaFirefox
```

### PDF viewer

#### zathura

```
sudo zypper install --no-recommends zathura poppler-data zathura-plugin-pdf-poppler
```

