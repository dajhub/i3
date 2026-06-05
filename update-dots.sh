#!/bin/sh
set -e

DOTDIR="$HOME/mango"

sync_dir() {
    src="$1"
    dest="$DOTDIR/$2"

    echo "Syncing $src → $dest"
    rsync -a --delete "$src/" "$dest/"
}

sync_file() {
    src="$1"
    dest="$DOTDIR/$2"

    echo "Copying $src → $dest"
    rsync -a "$src" "$dest"
}


# config directories
sync_dir "$HOME/.config/gtk-3.0" ".config/gtk-"3.0
sync_dir "$HOME/.config/helix" ".config/helix"
sync_dir "$HOME/.config/hypr" ".config/hypr"
sync_dir "$HOME/.config/kitty" ".config/kitty"
sync_dir "$HOME/.config/mango" ".config/mango"
sync_dir "$HOME/.config/micro" ".config/micro"
sync_dir "$HOME/.config/rofi" ".config/rofi"
sync_dir "$HOME/.config/waybar" ".config/waybar"
sync_dir "$HOME/.config/yazi" ".config/yazi"

sync_dir "$HOME/Pictures/Wallpapers" "Pictures/Wallpapers"


# fonts/themes/icons
sync_dir "$HOME/.fonts" ".fonts"


# zshrc file
sync_file "$HOME/.zshrc" ".zshrc"