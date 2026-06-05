#!/usr/bin/env bash

# Detect session
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
  kitty --override 'include colors/nord-light.conf'
elif [[ "$XDG_CURRENT_DESKTOP" == "sway" ]]; then
  kitty --override 'include colors/nord-vibrant.conf'
else
  kitty # fallback
fi