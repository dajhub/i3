#!/bin/bash

# Battery notification thresholds
THRESHOLDS=(20 15 10 5)
NOTIFIED=()

# Function to check battery status
check_battery() {
    # Get battery percentage (remove % sign)
    local battery_percent=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "100")
    local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
    
    echo $battery_percent $status
}

# Function to send notification
send_notification() {
    local level=$1
    local percent=$2
    local urgency="normal"
    
    case $level in
        5) urgency="critical" ;;
        10) urgency="critical" ;;
        *) urgency="normal" ;;
    esac
    
    notify-send -u $urgency "Battery Low" "Battery is at ${percent}%!\nPlug in your charger soon." -i battery-low
}

# Main monitoring loop
while true; do
    read percent status < <(check_battery)
    if [ "$status" = "Discharging" ]; then
        for threshold in "${THRESHOLDS[@]}"; do
            if [[ ! " ${NOTIFIED[@]} " =~ " ${threshold} " ]] && [ "$percent" -le "$threshold" ]; then
                send_notification $threshold $percent
                NOTIFIED+=($threshold)
                if [ "$threshold" -le 10 ]; then
                    paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
                fi
            fi
        done
    else
        # If charging, reset notifications
        NOTIFIED=()
    fi
    
    sleep 60  # Check every minute
done
