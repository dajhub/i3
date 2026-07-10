#!/bin/sh

# Font
FONT="UbuntuMono-10"

# Colors
NB="#303446" # normal background (Base)
NF="#c6d0f5" # normal foreground (Text)
SB="#8caaee" # selected background (Blue)
SF="#232634" # selected foreground (Crust)

# Launch dmenu_run with theme
dmenu_run -l 10 -fn "$FONT" -nb "$NB" -nf "$NF" -sb "$SB" -sf "$SF"
