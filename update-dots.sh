#!/bin/sh
set -e

DOTDIR="$HOME/i3"

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
sync_dir "$HOME/.config/betterlockscreen" ".config/betterlockscreen"
sync_dir "$HOME/.config/gtk-3.0" ".config/gtk-3.0"
sync_dir "$HOME/.config/helix" ".config/helix"
sync_dir "$HOME/.config/dunst" ".config/dunst"
sync_dir "$HOME/.config/kitty" ".config/kitty"
sync_dir "$HOME/.config/i3" ".config/i3"
sync_dir "$HOME/.config/micro" ".config/micro"
sync_dir "$HOME/.config/yazi" ".config/yazi"


# fonts/themes/icons
sync_dir "$HOME/.fonts" ".fonts"
sync_dir "$HOME/.themes" ".themes"
sync_dir "$HOME/.icons" ".icons"


# zshrc file
sync_file "$HOME/.zshrc" ".zshrc"