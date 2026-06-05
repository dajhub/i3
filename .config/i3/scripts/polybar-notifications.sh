#!/bin/bash
# ~/.jotalea/polybar-notifications.sh - Manage notifications via polybar

NOTIFICATION_DB="$HOME/.local/share/notifications.db"
ACTIVE_NOTIFICATIONS="/tmp/active-notifications.list"
OVERLAY_VISIBLE="/tmp/polybar-overlay-visible"

init_db() {
    sqlite3 "$NOTIFICATION_DB" "CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_name TEXT,
        summary TEXT,
        body TEXT,
        urgency TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        read BOOLEAN DEFAULT 0
    );" 2>/dev/null
}

add_notification() {
    local app="$1" summary="$2" body="$3" urgency="$4"
    init_db
    
    sqlite3 "$NOTIFICATION_DB" "INSERT INTO notifications (app_name, summary, body, urgency) 
                               VALUES ('$app', '$summary', '$body', '$urgency');"
    
    # Show overlay when new notification arrives
    show_overlay
}

list_notifications() {
    if [ ! -f "$ACTIVE_NOTIFICATIONS" ] || [ ! -s "$ACTIVE_NOTIFICATIONS" ]; then
        echo "No notifications"
        return
    fi
    
    # Show last 3 notifications
    local count=0
    local output=""
    
    tail -3 "$ACTIVE_NOTIFICATIONS" | while IFS='|' read -r timestamp app summary body urgency id; do
        # Truncate long text for polybar
        local short_summary="${summary:0:25}"
        local short_body="${body:0:25}"
        
        if [ $count -eq 0 ]; then
            echo "${short_summary} | ${short_body}"
        else
            echo "│ ${short_summary} | ${short_body}"
        fi
        
        count=$((count + 1))
    done | head -3
}

music_status() {
    if [ -S "/tmp/mpv-socket" ]; then
        ~/.jotalea/music.sh status 2>/dev/null || echo "Music playing"
    else
        echo "No music"
    fi
}

show_overlay() {
    # Start the overlay bar if not running
    if ! pgrep -f "polybar.*notifications" > /dev/null; then
        polybar notifications &
        echo "1" > "$OVERLAY_VISIBLE"
    fi
}

hide_overlay() {
    pkill -f "polybar.*notifications"
    rm -f "$OVERLAY_VISIBLE"
}

toggle_overlay() {
    if [ -f "$OVERLAY_VISIBLE" ]; then
        hide_overlay
    else
        show_overlay
    fi
}

clear_all() {
    > "$ACTIVE_NOTIFICATIONS"
    sqlite3 "$NOTIFICATION_DB" "UPDATE notifications SET read = 1;"
}

show_history() {
    # Could launch a terminal with notification history
    alacritty -e bash -c "echo 'Notification History:'; sqlite3 $NOTIFICATION_DB 'SELECT datetime(timestamp), app_name, summary FROM notifications ORDER BY timestamp DESC LIMIT 20;'; read"
}

# Handle commands
case "$1" in
    add)
        add_notification "$2" "$3" "$4" "$5"
        ;;
    list)
        list_notifications
        ;;
    music-status)
        music_status
        ;;
    show-overlay)
        show_overlay
        ;;
    hide-overlay)
        hide_overlay
        ;;
    toggle-overlay)
        toggle_overlay
        ;;
    clear-all)
        clear_all
        ;;
    show-history)
        show_history
        ;;
    *)
        echo "Usage: $0 {add|list|show-overlay|hide-overlay|clear-all}"
        ;;
esac
