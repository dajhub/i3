#!/usr/bin/env bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr" >/dev/null; then
  PRIMARY_DISPLAY=$(xrandr --query | grep " primary" | cut -d" " -f1)

  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [ "$m" == "$PRIMARY_DISPLAY" ]; then
      MONITOR=$m polybar --reload --config=~/.config/i3/polybar/config.ini main &
    else
      MONITOR=$m polybar --reload --config=~/.config/i3/polybar/config.ini secondary &
    fi
  done
else
  polybar --reload --config=~/.config/i3/polybar/config.ini main &
fi
