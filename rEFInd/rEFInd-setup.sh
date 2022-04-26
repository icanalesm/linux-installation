#!/bin/sh

refind_ver=0.13.3.1
refind_dir="refind-bin-$refind_ver"
refind_file="refind-bin-$refind_ver.zip"
install_dir=/boot/EFI/refind

wget "https://downloads.sourceforge.net/project/refind/$refind_ver/$refind_file"
unzip "$refind_file"
mkdir -p "$install_dir"
cp -r "$refind_dir/refind/"* "$install_dir/"
rm -r "$install_dir/"*ia32* "$install_dir/"*aa64*
mv "$install_dir/refind.conf-sample" "$install_dir/refind.conf"

git clone https://github.com/bobafetthotmail/refind-theme-regular.git
git clone https://github.com/htower/refind-theme-regular-black.git
mkdir -p "$install_dir/theme/icons"
cp "refind-theme-regular/icons/256-96/"* "$install_dir/theme/icons/"
cp "refind-theme-regular-black/icons/256-96/bg.png" "$install_dir/theme/icons/bg_black.png"
cp "refind-theme-regular-black/icons/256-96/selection-big.png" "$install_dir/theme/icons/selection_black-big.png"
cp "refind-theme-regular-black/icons/256-96/selection-small.png" "$install_dir/theme/icons/selection_black-small.png"

printf "\
#
# myconf.conf
#

timeout 20
use_nvram false
hideui label,singleuser,hints
use_graphics_for linux,windows
showtools shell,gdisk,memtest,mok_tool,apple_recovery,windows_recovery,about,hidden_tags,firmware,reboot,exit
scanfor manual,external

icons_dir theme/icons
big_icon_size 128
small_icon_size 48
banner theme/icons/bg.png
selection_big theme/icons/selection-big.png
selection_small theme/icons/selection-small.png" >> "$install_dir/myconf.conf"
