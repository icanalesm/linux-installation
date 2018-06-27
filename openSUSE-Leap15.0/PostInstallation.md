# openSUSE Leap 15.0 post-installation guide

The objective of this guide is to configure a minimal openSUSE system installation as described in [Installation.md](Installation.md).


## Post installation

### Configure keyboard layout

```
sudo localectl set-keymap <map>
```

where *<map>* is one of the available keyboard mappings from

```
localectl list-keymaps
```

### Hostname

Open `/etc/hostname` and replace the default hostname with the desired new hostname *<new hostname>*.

Open `/etc/hosts` and add 

```
127.0.1.1 <new hostname>.localdomain <new hostname>
```

in a new line after `127.0.0.1 localhost`.

Finally, check that the new configuration works by executing

```
ping <new hostname>
```

### X Window System

```
sudo zypper install --no-recommends xorg-x11-server xorg-x11-fonts xorg-x11-driver-video xorg-x11-driver-input xinit
```

In order to execute X without a display manager, open `/etc/permissions.local` and uncomment the line

```
/usr/bin/Xorg  root:root  4711
```

then execute

```
sudo chkstat --system --set
```

### Window manager

#### dwm

If required, install the required library dependencies

```
sudo zypper install --no-recommends libX11-devel libXft-devel libXinerama-devel
```

Download [dwm](https://dwm.suckless.org/), apply the desired customisations and patches, build and install.

To execute dwm, add `exec dwm` in a new line at the end of `~/.xinitrc` and execute `startx`.

My customised version of dwm: [github.com/icanalesm/dwm](https://github.com/icanalesm/dwm).

#### twm

```
sudo zypper install --no-recommends twm
```

### Terminal emulator

```
sudo zypper install --no-recommends rxvt-unicode
```

### Backlight

#### Screen backlight

Copy the file `scripts/backlight-screen` to `/usr/local/bin` and update its permissions

```
sudo cp <path to this repo>/scripts/backlight-screen /usr/local/bin/
sudo chmod 755 /usr/local/bin/backlight-screen
```

Allow user *<user>* to execute the script without password by executing

```
sudo visudo -f /etc/sudoers.d/backlight
```
and adding the following line

```
<user> ALL=NOPASSWD:/usr/local/bin/backlight-screen
```

#### Keyboard backlight

Copy the file `scripts/backlight-kbd` to `/usr/local/bin` and update its permissions

```
sudo cp <path to this repo>/scripts/backlight-kbd /usr/local/bin/
sudo chmod 755 /usr/local/bin/backlight-kbd
```

Allow user *<user>* to execute the script without password by executing

```
sudo visudo -f /etc/sudoers.d/backlight
```
and adding the following line

```
<user> ALL=NOPASSWD:/usr/local/bin/backlight-kbd
```

### Sound

```
sudo zypper install --no-recommends alsa alsa-oss alsa-plugins alsa-utils
```

Execute `alsamixer` to adjust the required playback controls.

### Web browser

```
sudo zypper install --no-recommends MozillaFirefox
```
