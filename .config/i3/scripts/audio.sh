#!/bin/bash
# ~/.jotalea/audio-switch.sh - Automatic audio switching for USB-C earphones

LOG_FILE="/tmp/audio-switch.log"
MODE="$1"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

notify() {
    notify-send -a "Audio Switch" "$1" "$2"
}

switch_to_earphones() {
    log "Switching to USB-C earphones"
    
    # Set the USB-C earphones as default
    earphones_sink=$(pactl list sinks short | grep "AB13X" | head -1 | cut -f2)
    
    if [ -n "$earphones_sink" ]; then
        # Set as default sink (output)
        pactl set-default-sink "$earphones_sink"
        log "Set default sink to: $earphones_sink"
        
        # Set as default source (input/microphone)  
        earphones_source=$(pactl list sources short | grep "AB13X" | grep -v ".monitor" | head -1 | cut -f2)
        if [ -n "$earphones_source" ]; then
            pactl set-default-source "$earphones_source"
            log "Set default source to: $earphones_source"
        fi
        
        # Move all existing audio streams to earphones
        pactl list sink-inputs short | cut -f1 | while read stream; do
            pactl move-sink-input "$stream" "$earphones_sink"
        done
        
        pactl list source-outputs short | cut -f1 | while read stream; do
            pactl move-source-output "$stream" "$earphones_source"
        done
        
        notify "Audio Switched" "Output set to USB-C Earphones"
    else
        log "ERROR: Could not find USB-C earphones sink"
        notify "Audio Switch" "Could not find USB-C earphones"
    fi
}

switch_to_speakers() {
    log "Switching to speakers"
    
    # Find internal speakers (AVS HDMI card)
    speaker_sink=$(pactl list sinks short | grep "alsa_card.platform-avs_hdaudio.2" | head -1 | cut -f2)
    
    if [ -n "$speaker_sink" ]; then
        # Set as default sink
        pactl set-default-sink "$speaker_sink"
        log "Set default sink to: $speaker_sink"
        
        # Move all audio streams back to speakers
        pactl list sink-inputs short | cut -f1 | while read stream; do
            pactl move-sink-input "$stream" "$speaker_sink"
        done
        
        # Set default source back to USB microphone if available, or internal
        usb_mic_source=$(pactl list sources short | grep "C-Media" | grep -v ".monitor" | head -1 | cut -f2)
        if [ -n "$usb_mic_source" ]; then
            pactl set-default-source "$usb_mic_source"
            log "Set default source to: $usb_mic_source"
        fi
        
        notify "Audio Switched" "Output set to Speakers"
    else
        log "ERROR: Could not find speaker sink"
    fi
}

# Main logic
case "$MODE" in
    "usbc-earphones")
        log "USB-C earphones plugged in"
        sleep 1  # Wait for device initialization
        switch_to_earphones
        ;;
    "speakers")
        log "USB-C earphones unplugged"
        switch_to_speakers
        ;;
    "status")
        echo "=== Audio Status ==="
        echo "Default Sink: $(pactl get-default-sink)"
        echo "Default Source: $(pactl get-default-source)"
        echo ""
        echo "Available Sinks:"
        pactl list sinks short
        echo ""
        echo "Available Sources:"
        pactl list sources short | head -10
        ;;
    "test-earphones")
        switch_to_earphones
        ;;
    "test-speakers")
        switch_to_speakers
        ;;
    *)
        echo "Usage: $0 {usbc-earphones|speakers|status|test-earphones|test-speakers}"
        echo ""
        echo "Manual testing:"
        echo "  $0 test-earphones    - Switch to USB-C earphones"
        echo "  $0 test-speakers     - Switch to speakers"
        echo "  $0 status            - Show current audio status"
        ;;
esac
