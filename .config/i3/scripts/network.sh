#!/usr/bin/env bash

# Get current Wi-Fi connection status
CON_STATE=$(nmcli -fields WIFI g)

if [[ "$CON_STATE" =~ "disabled" ]]; then
    TOGGLE="Turn Wi-Fi On"
else
    TOGGLE="Turn Wi-Fi Off"
fi

# Get current network name
CURRENT_WIFI=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)
[ -z "$CURRENT_WIFI" ] && CURRENT_WIFI="Disconnected"

# Get available Wi-Fi list
WIFI_LIST=$(nmcli --fields SSID,SECURITY dev wifi list | sed '1d' | grep -v '^--' | awk '!seen[$0]++')

# Display menu via rofi
CHOSEN=$(printf "%s\n%s\n%s" "Current: $CURRENT_WIFI" "$TOGGLE" "$WIFI_LIST" | rofi -config ~/.config/i3/rofi/config.rasi -dmenu -p "Wi-Fi Manager:" -i)

# Handle user selection
if [ -z "$CHOSEN" ] || [[ "$CHOSEN" == "Current:"* ]]; then
    exit 0
elif [[ "$CHOSEN" == "Turn Wi-Fi On" ]]; then
    nmcli radio wifi on
elif [[ "$CHOSEN" == "Turn Wi-Fi Off" ]]; then
    nmcli radio wifi off
else
    # Extract SSID accurately, even with trailing spaces or spaces in the name
    SSID=$(echo "$CHOSEN" | sed -E 's/\s+(WPA|WEP|802\.1X|--).*//g' | xargs)
    
    # Check if network requires a password
    if [[ "$CHOSEN" =~ "WPA" || "$CHOSEN" =~ "WEP" ]]; then
        PASS=$(rofi -config ~/.config/i3/rofi/config.rasi -dmenu -p "Enter Password for $SSID:" -password)
        [ -z "$PASS" ] && exit 0
        nmcli dev wifi connect "$SSID" password "$PASS"
    else
        nmcli dev wifi connect "$SSID"
    fi
fi
