#!/bin/bash

set -e


# --- 1. Variables ---
MAGENTA='\033[35m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_DIR="$HOME/.config"
DOTFILES_SRC="$HOME/i3" 
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
msg() { echo -e "${CYAN}$*${NC}"; }
warn() { echo -e "${YELLOW}WARNING: $*${NC}"; }


# --- 2. Section Headers
section() {
    echo -e "${MAGENTA}=========================================${NC}"
    echo -e "${MAGENTA}>>>>> $1 ${NC}"
    echo -e "${MAGENTA}=========================================${NC}\n"
}


# --- 3. Packages Definitions ---
PACKAGES_CORE=(i3 i3status xorg-x11-server-Xorg xorg-x11-xinit NetworkManager-wifi lightdm slick-greeter)
PACKAGES_UI=(polybar picom rofi dunst feh)
PACKAGES_SCREENSHOTS=(xclip maim)
PACKAGES_TERMINAL=(kitty zsh)
PACKAGES_EDITORS=(micro helix)
#PACKAGES_FILE_MANAGER=(yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick unzip)
PACKAGES_THUNAR=(gvfs Thunar thunar-archive-plugin thunar-volman tumbler xarchiver unzip)
#PACKAGES_FONTS=(inter-font ttf-jetbrains-mono ttf-roboto-serif ttf-hellvetica ttf-ubuntu-font-family)
PACKAGES_AUDIO=(pipewire pipewire-pulseaudio pipewire-alsa wireplumber pavucontrol alsa-utils bluez bluez-libs)
PACKAGES_APPEARANCE=(brightnessctl)
PACKAGES_UTILITIES=(curl lua  xrandr xset xdg-user-dirs viewnior htop rsync fastfetch)
PACKAGES_PRINTER=(hplip cups ipp-usb system-config-printer cups-pk-helper)


# --- 4 Installation Logic ---
ONLY_CONFIG="${ONLY_CONFIG:-false}"
if [ "$ONLY_CONFIG" = false ]; then
    section "INSTALLING ALL PACKAGES"
    
    ALL_PACKAGES=("${PACKAGES_CORE[@]}" "${PACKAGES_UI[@]}" "${PACKAGES_SCREENSHOTS[@]}" "${PACKAGES_TERMINAL[@]}" "${PACKAGES_EDITORS[@]}" "${PACKAGES_THUNAR[@]}" "${PACKAGES_FONTS[@]}" "${PACKAGES_AUDIO[@]}" "${PACKAGES_APPEARANCE[@]}" "${PACKAGES_UTILITIES[@]}" "${PACKAGES_PRINTER[@]}")
    
    sudo dnf install -y "${ALL_PACKAGES[@]}" || die "package installation failed"
fi


# -- 5. Installing bzmenu for bluetooth ---
section "INSTALLING BZMENU"
sudo dnf install rust cargo pkg-config dbus-devel
git clone https://github.com/e-tho/bzmenu
cd bzmenu
cargo build --release
install -Dm755 target/release/bzmenu ~/.local/bin/bzmenu
cd

# -- 6. Installing autotiling for i3 ---
# Enable the community repo that packages autotiling
section "AUTOTILING"
sudo dnf copr enable erikreider/packages
sudo dnf install autotiling

# -- 7. Installing betterlockscreen ---
section "BETTERLOCKSCREEN"
sudo dnf install -y autoconf automake cairo-devel fontconfig gcc libev-devel libjpeg-turbo-devel libXinerama libxkbcommon-devel libxkbcommon-x11-devel libXrandr pam-devel pkgconf xcb-util-image-devel xcb-util-xrm-devel giflib-devel
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
./install-i3lock-color.sh

sudo dnf install -y ImageMagick bc

wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system

# -- 8. Installing Flathub ---
section "FLATPACK, FLATHUB & PACKAGES"
sudo dnf install -y flatpak flatseal
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo dnf upgrade --refresh -y
# Packages
flatpak install flathub io.gitlab.librewolf-community
flatpak install flathub com.vivaldi.Vivaldi
flatpak install flathub net.cozic.joplin_desktop
flatpak install flathub org.onlyoffice.desktopeditors


# --- 9. Configure Shell ---
section "CONFIGURING SHELL"
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
chsh -s /usr/bin/zsh


# --- 10. Configuration & Dotfiles ---
section "SETTING UP FOLDERS & DOTFILES"

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


# --- 11. Enable services ---
sudo systemctl start bluetooth
sudo systemctl enable bluetooth
sudo systemctl enable cups
sudo systemctl enable lightdm
systemctl set-default graphical.target


### END ###
section "FINISHED: REBOOT..."


