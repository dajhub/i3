#!/bin/bash
# ~/.jotalea/music.sh
# Unified music controller for polybar with scrolling text

SOCKET="/tmp/mpv-socket"
ACTION="${1:-status}"
SCROLL_FILE="/tmp/music-scroll-position"

# Scrolling function
get_scrolled_text() {
    local text="$1"
    local max_length="${2:-30}"
    local scroll_speed="${3:-1}"  # Characters to move per call
    
    # If text is shorter than max, just return it
    if [ ${#text} -le $max_length ]; then
        echo "$text"
        return
    fi
    
    # Initialize or read scroll position
    if [ ! -f "$SCROLL_FILE" ]; then
        echo "0" > "$SCROLL_FILE"
    fi
    
    local position=$(cat "$SCROLL_FILE")
    local text_length=${#text}
    
    # Calculate padded text (text + spaces + text to create seamless loop)
    local padded_text="${text}    ${text}"
    local padded_length=${#padded_text}
    
    # Extract the visible portion
    local visible_text="${padded_text:position:max_length}"
    
    # Update position for next call
    position=$(( (position + scroll_speed) % (text_length + 4) ))  # +4 for the spaces
    
    # Save new position
    echo "$position" > "$SCROLL_FILE"
    
    echo "$visible_text"
}

case "$ACTION" in
    status)
        if [ ! -S "$SOCKET" ]; then
            # Reset scroll position when music stops
            rm -f "$SCROLL_FILE"
            exit 0
        fi

        # Try multiple methods to get track info
        TRACK=""
        
        # Method 1: Try to get media-title
        RESPONSE=$(echo '{ "command": ["get_property", "media-title"] }' | socat - "$SOCKET" 2>/dev/null)
        if echo "$RESPONSE" | grep -q '"data":"'; then
            TRACK=$(echo "$RESPONSE" | grep -o '"data":"[^"]*"' | cut -d'"' -f4 | sed 's/\.m4a$//')
        fi
        
        # Method 2: If media-title failed, try to get filename from path
        if [ -z "$TRACK" ]; then
            RESPONSE=$(echo '{ "command": ["get_property", "path"] }' | socat - "$SOCKET" 2>/dev/null)
            if echo "$RESPONSE" | grep -q '"data":"'; then
                TRACK=$(echo "$RESPONSE" | grep -o '"data":"[^"]*"' | cut -d'"' -f4 | xargs basename | sed 's/\.m4a$//')
            fi
        fi
        
        # Method 3: If still no track, use generic name
        if [ -z "$TRACK" ]; then
            TRACK="Music Player"
            rm -f "$SCROLL_FILE"  # Reset scroll for generic text
        fi

        # Get pause state
        PAUSE_RESPONSE=$(echo '{ "command": ["get_property", "pause"] }' | socat - "$SOCKET" 2>/dev/null)
        if echo "$PAUSE_RESPONSE" | grep -q '"data":true'; then
            STATE="⏸"
        else
            STATE="▶"
        fi

        # Get scrolled text (max 28 chars to leave space for state icon)
        SCROLLED_TEXT=$(get_scrolled_text "$TRACK" 28)
        echo "$STATE $SCROLLED_TEXT"
        ;;

    prev|previous)
        # Reset scroll position when changing tracks
        rm -f "$SCROLL_FILE"
        if [ -S "$SOCKET" ]; then
            echo '{ "command": ["playlist-prev"] }' | socat - "$SOCKET" 2>/dev/null
        fi
        ;;

    toggle|pause)
        if [ -S "$SOCKET" ]; then
            echo '{ "command": ["cycle", "pause"] }' | socat - "$SOCKET" 2>/dev/null
        fi
        ;;

    next)
        # Reset scroll position when changing tracks
        rm -f "$SCROLL_FILE"
        if [ -S "$SOCKET" ]; then
            echo '{ "command": ["playlist-next"] }' | socat - "$SOCKET" 2>/dev/null
        fi
        ;;

    stop|quit)
        # Clean up scroll file when stopping
        rm -f "$SCROLL_FILE"
        if [ -S "$SOCKET" ]; then
            echo '{ "command": ["quit"] }' | socat - "$SOCKET" 2>/dev/null
            rm -f "$SOCKET"
        fi
        ;;

    reset-scroll)
        # Manual reset of scroll position
        rm -f "$SCROLL_FILE"
        echo "Scroll position reset"
        ;;

    debug)
        if [ -S "$SOCKET" ]; then
            echo "=== MPV Debug Info ==="
            echo "Pause state:"
            echo '{ "command": ["get_property", "pause"] }' | socat - "$SOCKET"
            echo "Media title:"
            echo '{ "command": ["get_property", "media-title"] }' | socat - "$SOCKET"
            echo "Path:"
            echo '{ "command": ["get_property", "path"] }' | socat - "$SOCKET"
        else
            echo "Socket not found"
        fi
        ;;

    *)
        echo "Usage: $0 {status|prev|toggle|next|stop|reset-scroll|debug}"
        exit 1
        ;;
esac
