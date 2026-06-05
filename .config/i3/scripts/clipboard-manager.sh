#!/bin/bash
# ~/.jotalea/clipboard-manager.sh - Fixed clipboard manager

CLIPBOARD_DIR="$HOME/.local/share/clipboard"
CLIPBOARD_DB="$CLIPBOARD_DIR/history.db"
MAX_ITEMS=100

init_clipboard() {
    mkdir -p "$CLIPBOARD_DIR"
    sqlite3 "$CLIPBOARD_DB" "CREATE TABLE IF NOT EXISTS clips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    );" 2>/dev/null
}

clipboard_monitor() {
    init_clipboard
    local last_content=""
    
    echo "Clipboard monitor started..."
    
    while true; do
        local current_content=$(xclip -selection clipboard -o 2>/dev/null)
        
        if [ -n "$current_content" ] && [ "$current_content" != "$last_content" ]; then
            # Clean content for SQL insertion - handle single quotes properly
            local clean_content=$(printf "%q" "$current_content" | sed "s/^'//;s/'$//")
            
            # Avoid duplicates
            local existing=$(sqlite3 "$CLIPBOARD_DB" "SELECT COUNT(*) FROM clips WHERE content = '$clean_content';")
            
            if [ "$existing" -eq 0 ]; then
                sqlite3 "$CLIPBOARD_DB" "INSERT INTO clips (content) VALUES ('$clean_content');"
                echo "New clip: $(echo "$current_content" | head -c 50)..."
                
                # Trim old entries
                sqlite3 "$CLIPBOARD_DB" "DELETE FROM clips WHERE id NOT IN (
                    SELECT id FROM clips ORDER BY timestamp DESC LIMIT $MAX_ITEMS
                );"
            fi
            
            last_content="$current_content"
        fi
        
        sleep 1
    done
}

show_clipboard_menu() {
    init_clipboard
    
    # Get clipboard history with proper formatting
    local menu_items=$(sqlite3 "$CLIPBOARD_DB" "SELECT id, content FROM clips ORDER BY timestamp DESC LIMIT 20;" | \
        while IFS='|' read -r id content; do
            # Clean and truncate the content
            clean_content=$(echo "$content" | sed 's/\\n/ /g' | tr -d '\n' | head -c 80)
            if [ ${#content} -gt 80 ]; then
                clean_content="${clean_content}..."
            fi
            echo -e "$id\t$clean_content"
        done)
    
    if [ -z "$menu_items" ]; then
        notify-send "Clipboard" "No clipboard history yet"
        return
    fi
    
    # Use rofi with proper formatting
    local selected=$(echo "$menu_items" | rofi -dmenu -p "" -format 'i' -i)
    
    if [ -n "$selected" ] && [ "$selected" -ge 0 ]; then
        # Get the ID from the selected line (add 1 because rofi returns 0-indexed)
        local line_num=$((selected + 1))
        local selected_id=$(echo "$menu_items" | sed -n "${line_num}p" | cut -f1)
        
        if [ -n "$selected_id" ]; then
            local content=$(sqlite3 "$CLIPBOARD_DB" "SELECT content FROM clips WHERE id = $selected_id;")
            # Properly handle the content - remove escaping and copy to clipboard
            printf "%s" "$content" | xclip -selection clipboard
            notify-send "Clipboard" "Item copied to clipboard"
        fi
    fi
}

# Alternative simpler menu that definitely works
show_clipboard_menu_simple() {
    init_clipboard
    
    # Simple approach - just show the content directly
    local selected=$(sqlite3 "$CLIPBOARD_DB" "SELECT content FROM clips ORDER BY timestamp DESC LIMIT 20;" | \
        while read -r content; do
            echo "$content" | sed 's/\\n/ /g' | tr -d '\n' | head -c 80
        done | \
        rofi -dmenu -p "Clipboard")
    
    if [ -n "$selected" ]; then
        echo "$selected" | xclip -selection clipboard
        notify-send "Clipboard" "Item copied to clipboard"
    fi
}

show_clipboard_tui() {
    # Terminal-based interface
    while true; do
        clear
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                     CLIPBOARD MANAGER                   ║"
        echo "╠══════════════════════════════════════════════════════════╣"
        
        # Show recent clips with proper formatting
        sqlite3 "$CLIPBOARD_DB" "SELECT id, datetime(timestamp) as Time, substr(replace(content, char(10), ' '), 1, 40) as Preview FROM clips ORDER BY timestamp DESC LIMIT 10;" | \
            while IFS='|' read -r id time preview; do
                printf "║ %2d | %s | %-40s ║\n" "$id" "$time" "$preview"
            done
        
        echo "╠══════════════════════════════════════════════════════════╣"
        echo "║ [1-10] Copy Item  [D] Delete  [C] Clear All  [Q] Quit   ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo -n "Select: "
        
        read -n 1 choice
        case "$choice" in
            [1-9])
                local id=$(sqlite3 "$CLIPBOARD_DB" "SELECT id FROM clips ORDER BY timestamp DESC LIMIT 10 OFFSET $((choice-1));")
                if [ -n "$id" ]; then
                    local content=$(sqlite3 "$CLIPBOARD_DB" "SELECT content FROM clips WHERE id = $id;")
                    printf "%s" "$content" | xclip -selection clipboard
                    echo -e "\nCopied item $choice"
                    sleep 1
                fi
                ;;
            0)
                local id=$(sqlite3 "$CLIPBOARD_DB" "SELECT id FROM clips ORDER BY timestamp DESC LIMIT 10 OFFSET 9;")
                if [ -n "$id" ]; then
                    local content=$(sqlite3 "$CLIPBOARD_DB" "SELECT content FROM clips WHERE id = $id;")
                    printf "%s" "$content" | xclip -selection clipboard
                    echo -e "\nCopied item 10"
                    sleep 1
                fi
                ;;
            d|D)
                echo -n "Enter ID to delete: "
                read id
                sqlite3 "$CLIPBOARD_DB" "DELETE FROM clips WHERE id = $id;"
                echo "Deleted item $id"
                sleep 1
                ;;
            c|C)
                sqlite3 "$CLIPBOARD_DB" "DELETE FROM clips;"
                echo "Cleared all clips"
                sleep 1
                ;;
            q|Q)
                break
                ;;
        esac
    done
}

clipboard_stats() {
    init_clipboard
    local total=$(sqlite3 "$CLIPBOARD_DB" "SELECT COUNT(*) FROM clips;")
    local latest=$(sqlite3 "$CLIPBOARD_DB" "SELECT content FROM clips ORDER BY timestamp DESC LIMIT 1;")
    local clean_latest=$(echo "$latest" | sed 's/\\n/ /g' | tr -d '\n' | head -c 30)
    
    #echo "$total clips | ${clean_latest:-Empty}"
    echo "clip"
}

# Main command handler
case "$1" in
    "monitor")
        clipboard_monitor
        ;;
    "menu")
        show_clipboard_menu_simple  # Use the simple version for now
        ;;
    "tui")
        show_clipboard_tui
        ;;
    "stats")
        clipboard_stats
        ;;
    "add")
        printf "%s" "$2" | xclip -selection clipboard
        ;;
    "show")
        xclip -selection clipboard -o
        ;;
    "debug")
        echo "=== Clipboard DB Contents ==="
        sqlite3 "$CLIPBOARD_DB" "SELECT id, datetime(timestamp), substr(content, 1, 50) FROM clips ORDER BY timestamp DESC LIMIT 5;"
        ;;
    *)
        echo "Usage: $0 {monitor|menu|tui|stats|add|show|debug}"
        ;;
esac
