#!/bin/bash
# ~/.jotalea/polybar-ai.sh - Simple AI assistant via polybar

ask_question() {
    # Use dmenu/rofi for input
    question=$(rofi -dmenu -p "Ask AI:")
    
    if [ -n "$question" ]; then
        # Simple response (replace with actual AI)
        response="Question: '$question' - Add AI backend later"
        notify-send "AI Assistant" "$response"
    fi
}

take_screenshot() {
    scrot -s "/tmp/ai-screenshot-$(date +%s).png"
    notify-send "AI Assistant" "Screenshot saved for context"
}

system_info() {
    info="Distro: $(source /etc/os-release && echo $PRETTY_NAME)
Kernel: $(uname -r)
DE: $XDG_CURRENT_DESKTOP
Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    
    notify-send "System Info" "$info"
}

show_ai() {
    polybar ai-assistant &
}

hide_ai() {
    pkill -f "polybar.*ai-assistant"
}

case "$1" in
    ask-question) ask_question ;;
    take-screenshot) take_screenshot ;;
    system-info) system_info ;;
    show-ai) show_ai ;;
    hide-ai) hide_ai ;;
    *) echo "Usage: $0 {ask-question|take-screenshot|system-info}" ;;
esac
