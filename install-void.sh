#!/usr/bin/env bash

# Exit immediately if an show-error
set -e

# Messages
msg() { echo -e "--> \$1"; }
warn() { echo -e "\033[0;33m[WARN] \033[0m\$1"; }

echo "=== Starting Void Linux i3 + Polybar + SDDM Installation ==="

# 1. Update the package database
echo "--> Updating XBPS database..."
sudo xbps-install -S

# 2. Display Server & Graphics
echo "--> Installing X11 Display Server & Graphics Drivers"
sudo xbps-install -y \
  xorg-minimal \
  xf86-video-intel \
  mesa-dri

# 2a. Window Manager & Desktop Environment
echo "--> Installing Window Manager and Desktop Components"
sudo xbps-install -y \
  i3 \
  polybar \
  picom \
  autotiling

# 2b. Display Manager & Session Management
echo "--> Installing Session, Seat, and Login Management"
sudo xbps-install -y \
  sddm \
  seatd \
  dbus \
  elogind \
  polkit

# 2c. Desktop Utilities (Lockscreen, Launchers, Notifications)
echo "--> Installing Desktop Utilities & X11 Utilities"
sudo xbps-install -y \
  betterlockscreen \
  brightnessctl \
  rofi \
  dunst \
  feh \
  xset \
  xrandr \
  xclip \
  alacritty \
  maim

# 2d. X11 Development Headers (Optional but helpful for compilation)
echo "--> Installing X11 Development Libraries"
sudo xbps-install -y \
  libX11-devel \
  libXft-devel \
  libXinerama-devel

# 2e. Terminal & Editors
echo "--> Installing terminal and editors"
sudo xbps-install -y \
  kitty \
  zsh \
  micro \
  neovim
  
# 2f. Audio Stack (PipeWire)
msg "Installing PipeWire and Audio Utilities"
sudo xbps-install -y \
  pipewire \
  wireplumber \
  alsa-pipewire \
  pulseaudio-utils \
  pamixer

# 2g. Bluetooth
msg "Installing Bluetooth Stack and Managers"
sudo xbps-install -y \
  bluez \
  libspa-bluetooth \
  blueman
  
# 2h. Utilities
echo "--> Installing System & CLI Utilities"
sudo xbps-install -y \
  curl \
  unzip \
  base-devel \
  htop \
  bzmenu \
  rsync

# 2i. File manager
echo "--> File Manager"
sudo xbps-install -y \
  yazi \
  ffmpeg \
  7zip \
  jq \
  poppler \
  fd \
  ripgrep \
  fzf \
  zoxide \
  resvg \
  ImageMagick \
  unzip

# 2j. Browser
echo "--> Browser"
sudo xbps-install -y firefox

# Configure Shell
echo "--> Configuring Shell"
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
chsh -s /usr/bin/zsh "$USER"

# Configure runit services
echo "--> Enabling core system services..."
# Enable dbus (Required for elogind and SDDM)
if [ ! -L /var/service/dbus ]; then
  sudo ln -s /etc/sv/dbus /var/service/
fi

# Enable seatd (Handles graphics/input permissions)
if [ ! -L /var/service/seatd ]; then
  sudo ln -s /etc/sv/seatd /var/service/
fi

# Enable Bluetooth Daemon
if [ ! -L /var/service/bluetoothd ]; then
  sudo ln -s /etc/sv/bluetoothd /var/service/
fi

# Enable SDDM (This will bring up the graphical login screen on boot)
if [ ! -L /var/service/sddm ]; then
  sudo ln -s /etc/sv/sddm /var/service/
fi

# Add current user to required groups
echo "--> Adding user $USER to video, audio, and seat groups..."
sudo gpasswd -a "$USER" video
sudo gpasswd -a "$USER" audio
sudo gpasswd -a "$USER" _seatd
sudo gpasswd -a "$USER" bluetooth

# 4. Configuring directories for dotfiles
echo "--> Preparing config directories..."

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
echo "Next step:"
echo "REBOOT system."
echo "========================================================="
echo " Note: On reboot, SDDM will start automatically."
echo " Select 'i3' from the session dropdown menu before logging in!"
echo "========================================================="
