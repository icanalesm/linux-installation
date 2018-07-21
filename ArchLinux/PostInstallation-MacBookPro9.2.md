# ArchLinux post-installation guide - MacBook Pro 9.2

The objective of this guide is to configure an ArchLinux system installation on a MacBook Pro 9.2 as described in [Installation-MacBookPro9.2.md](Installation-MacBookPro9.2.md).

**WARNING**: Put special attention when installing packages from [AUR](https://aur.archlinux.org/). As stated in [ArchWiki's AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository):
> *Carefully check all files*. Carefully check the `PKGBUILD` and any .install file for malicious commands. `PKGBUILD`s are bash scripts containing functions to be executed by `makepkg`: these functions can contain any valid commands or Bash syntax, so it is totally possible for a `PKGBUILD` to contain dangerous commands through malice or ignorance on the part of the author. Since `makepkg` uses `fakeroot` (and should never be run as root), there is some level of protection but you should never count on it. If in doubt, do not build the package and seek advice on the forums or mailing list.


## Post installation

### Network manager

#### NetworkManager

```
sudo pacman -Syu networkmanager
sudo systemctl unmask NetworkManager.service
sudo systemctl enable --now NetworkManager.service
```

### Firewall

#### firewalld

```
sudo pacman -Syu firewalld
sudo systemctl unmask firewalld.service
sudo systemctl enable --now firewalld.service
```

### WiFi

#### Broadcom 4331

```
git clone https://aur.archlinux.org/b43-firmware.git
cd b43-firmware
makepkg -si
```

### NTP

#### chrony

```
sudo pacman -Syu chrony
```

`systemd-timesyncd.service` is in conflict with `chronyd.service`, so disable it first

```
sudo systemctl disable systemd-timesyncd.service
```

and then enable `chronyd.service`

```
sudo systemctl enable chronyd.service
```

Enable NetworkManager's dispatcher to inform *chrony* when the network status has changed

```
sudo systemctl enable NetworkManager-dispatcher.service
```

Install the dispatcher script

```
git clone https://aur.archlinux.org/networkmanager-dispatcher-chrony.git
cd networkmanager-dispatcher-chrony/
makepkg -si
```

### Fonts

#### Arimo, Cousine, Tinos

```
sudo pacman -Syu ttf-croscore
```

#### Font Awesome

```
sudo pacman -Syu ttf-font-awesome
```

#### Inconsolata

```
sudo pacman -Syu ttf-inconsolata 
```

#### Open Sans

```
git clone https://aur.archlinux.org/ttf-opensans.git
cd ttf-opensans
makepkg -si
```

### X Window System

```
sudo pacman -Syu xorg-server xf86-input-libinput xf86-video-intel xorg-xinit
```

### Window manager

#### dwm

If required, install the required library dependencies

```
sudo pacman lbx11 ibxft libxinerama
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
sudo pacman -Syu rxvt-unicode
```

#### xterm

```
sudo pacman -Syu xterm
```

### Color calibration

```
git clone https://aur.archlinux.org/xcalib.git
cd xcalib
makepkg -si
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
sudo pacman -Syu alsa-lib alsa-utils alsa-plugins
```

Execute `alsamixer` to adjust the required playback controls.

### Web browser

```
sudo pacman -Syu firefox
```

### Power management

#### TLP

```
sudo pacman -Syu tlp
```

Enable services required by `tlp` and mask `rfkill` service and socket to avoid conflicts

```
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

