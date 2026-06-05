#!/bin/bash

# Reload i3 config
i3-msg reload

# Kill existing polybar instances
killall -q polybar

# Wait until they are fully terminated
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# Optional: set monitor if needed
# export MONITOR=$(xrandr --query | grep " connected" | head -n 1 | cut -d" " -f1)

# Launch polybar with correct config and bar name
polybar main --config=$HOME/.config/i3/polybar/config.ini &
