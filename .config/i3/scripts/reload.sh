#!/bin/bash

# Restart i3 (re-reads config AND re-executes exec_always scripts)
i3-msg restart

# Execute your multi-monitor launch script directly
$HOME/.config/i3/polybar/launch.sh
