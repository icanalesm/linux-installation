# ArchLinux post-installation guide

The objective of this guide is to configure an ArchLinux system installation on a MacBook Por 9.2 as described in [Installation-MacBookPro9.2.md](Installation-MacBookPro9.2.md).

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

Download [dwm](https://dwm.suckless.org/), apply the desired customisations and patches, compile and install.

To execute dwm, add `exec dwm` in a new line at the end of `~/.xinitrc` and execute `startx`.

My customised version of dwm: [github.com/icanalesm/dwm](https://github.com/icanalesm/dwm).

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

Apply the desired configuration. Afterwards, compile and install

```
make
sudo make install
```

Allow user *\<user\>* to execute the script as *sudo* without password

```
sudo visudo -f /etc/sudoers.d/brightness
```

and adding the following line

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
