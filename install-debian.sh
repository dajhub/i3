#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Messages
msg() { echo -e "--> \033[1;32m$1\033[0m"; }
warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }

echo "=== Starting Debian 13 (Trixie) i3 + Polybar + SDDM Installation ==="

# 1. Update the package database
msg "Updating APT package database..."
sudo apt update && sudo apt upgrade -y

# 2. Display Server, NetworkManager & Graphics
msg "Installing X11 Display Server, Drivers, and Networking"
sudo apt install -y \
  xserver-xorg-core \
  xinit \
  x11-xserver-utils \
  xorg \
  xserver-xorg-video-intel \
  mesa-va-drivers \
  network-manager

# 2a. Window Manager & Desktop Environment
msg "Installing Window Manager and Desktop Components"
sudo apt install -y \
  i3 \
  polybar \
  picom \
  autotiling

# 2b. Display Manager & Session Management
msg "Installing Session and Login Management"
sudo apt install -y \
  dbus-x11 \
  mate-polkit

sudo apt install --no-install-recommends -y sddm

# 2c. Desktop Utilities (Lockscreen, Launchers, Notifications)
msg "Installing Desktop Utilities & X11 Utilities"
sudo apt install -y \
  brightnessctl \
  suckless-tools \
  rofi \
  dunst \
  feh \
  xclip \
  xdotool \
  xss-lock \
  alacritty \
  maim \
  bc \
  imagemagick

# BETTERLOCKSCREEN - source https://github.com/betterlockscreen/betterlockscreen?tab=readme-ov-file
# Install dependencies for i3lock-color
sudo apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libgif-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev
# Install i3lock-color
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
./install-i3lock-color.sh
# Additional dependencies for Betterlockscreen
sudo apt install -y imagemagick
# Install Betterlockscreen
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s user

# 2d. X11 Development Headers
#msg "Installing Development Libraries"
#sudo apt install -y \
#  libx11-dev \
#  libxft-dev \
#  libxinerama-dev \
#  build-essential

# 2e. Terminal & Editors
msg "Installing terminal and editors"
sudo apt install -y \
  kitty \
  zsh \
  micro

# Lazyvim needs a newer version of neovim:
sudo apt install -y curl
curl -sL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz |
  sudo tar -xzf - --strip-components=1 --overwrite -C /usr/local

# 2f. Audio Stack (PipeWire)
msg "Installing PipeWire and Audio Utilities"
sudo apt install -y \
  pipewire \
  wireplumber \
  pipewire-audio-client-libraries \
  pipewire-pulse \
  pipewire-alsa \
  alsa-utils \
  pulseaudio-utils \
  pamixer

# 2g. Bluetooth
msg "Installing Bluetooth Stack"
sudo apt install -y \
  bluez \
  blueman

# 2h. Utilities
msg "Installing System & CLI Utilities"
sudo apt install -y \
  unzip \
  htop \
  rsync \
  nodejs \
  lua5.4 \
  git

# 2i. File manager & Dependencies
msg "Installing File Manager & Command-line Tools"
curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' | sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null
sudo apt update && sudo apt install -y yazi

# 2j. Browser
msg "Installing Web Browser"
sudo apt install -y firefox-esr

# 2k. Fonts
msg "Installing Fonts"
sudo apt install -y \
  fonts-ubuntu \
  fonts-font-awesome

# Configure Shell
msg "Configuring Zsh Shell"
if [ ! -d "$HOME/.zinit" ]; then
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi
sudo chsh -s "$(which zsh)" "$USER"

# Configure systemd services
msg "Enabling core system services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable sddm

# Add user to required groups
msg "Adding user $USER to necessary groups..."
sudo usermod -aG video,audio,render,input "$USER"

# 4. Configuring directories for dotfiles
msg "Preparing config directories..."

CONFIG_DIR="$HOME/.config"
DOTFILES_SRC="$HOME/i3"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOTS_DIR"
mkdir -p "$WALLPAPERS_DIR"
mkdir -p "$CONFIG_DIR"

if [ -d "$DOTFILES_SRC" ]; then
  msg "Syncing dotfiles from $DOTFILES_SRC..."
  if [ -f "$DOTFILES_SRC/folders.sh" ]; then
    chmod +x "$DOTFILES_SRC/folders.sh"
    (cd "$DOTFILES_SRC" && ./folders.sh)
    msg "Folder sync complete."
  else
    warn "folders.sh not found in $DOTFILES_SRC."
  fi
else
  warn "Source directory $DOTFILES_SRC not found! Skipping dotfiles."
fi

echo "========================================================="
echo " Installation complete!"
echo "========================================================="
echo "Next step: Reboot your system."
echo "Note: SDDM will launch on startup. Select 'i3' from the session menu."
echo "========================================================="
