#!/bin/sh
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $REPO_DIR"

sync_dir() {
    src="$REPO_DIR/$1"
    dest="$HOME/$2"
    echo "Syncing directory $src → $dest"
    rsync -a --delete "$src/" "$dest/"
}

sync_file() {
    src="$REPO_DIR/$1"
    dest="$HOME/$2"
    echo "Copying file $src → $dest"
    rsync -a "$src" "$dest"
}

# Directories
sync_dir ".config/betterlockscreen" ".config/betterlockscreen"
sync_dir ".config/gtk-3.0" ".config/gtk-3.0"
sync_dir ".config/helix" ".config/helix"
sync_dir ".config/dunst" ".config/dunst"
sync_dir ".config/kitty" ".config/kitty"
sync_dir ".config/i3" ".config/i3"
sync_dir ".config/micro" ".config/micro"
sync_dir ".config/yazi" ".config/yazi"

sync_dir ".fonts" ".fonts"
sync_dir ".themes" ".themes"
sync_dir ".icons" ".icons"

# Files
sync_file ".zshrc" ".zshrc"


echo "Done."

