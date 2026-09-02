#!/usr/bin/env bash
set -e

# Define log files in the home directory
LOG_DIR="$HOME"
CURRENT_LOG="$LOG_DIR/.update-all.log"
PREV_LOG="$LOG_DIR/.update-all.log.1"

# Rotate log files: keep maximum of 2 logs
if [ -f "$PREV_LOG" ]; then
  rm -f "$PREV_LOG"
fi

if [ -f "$CURRENT_LOG" ]; then
  mv "$CURRENT_LOG" "$PREV_LOG"
fi

# Redirect all standard output and standard error to both the terminal and the current log file
exec > >(tee -a "$CURRENT_LOG") 2>&1

echo "=== System Update Started: $(date) ==="

echo "=== Updating APT Repositories ==="
sudo apt update

echo "=== Upgrading APT Packages ==="
sudo apt full-upgrade -y

echo "=== Cleaning Up Unused APT Packages & Cache ==="
sudo apt autoremove --purge -y
sudo apt clean
sudo apt autoclean

if command -v flatpak &>/dev/null; then
  echo "=== Updating Flatpaks ==="
  flatpak update -y

  echo "=== Cleaning Unused Flatpak Runtimes ==="
  flatpak uninstall --unused -y
fi

echo "=== System Update and Cleanup Complete: $(date) ==="
