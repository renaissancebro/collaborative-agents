#!/bin/bash

# Monitor script for Dual-Agent Code Review System

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
POSTBOX_DIR="../postbox"
WATCHER_DIR="../watcher"

clear_screen() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║               Dual-Agent Code Review Monitor                 ║${NC}"
    echo -e "${CYAN}║                    $(date '+%Y-%m-%d %H:%M:%S')                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_agent_status() {
    echo -e "${BLUE}🤖 Agent Status${NC}"
    echo "─────────────────"
    
    # Check Gemini agent
    if pgrep -f "gemini_loop.sh" > /dev/null; then
        local gemini_pid=$(pgrep -f "gemini_loop.sh")
        echo -e "${GREEN}✅ Gemini Agent${NC} (PID: $gemini_pid) - Running"
    else
        echo -e "${RED}❌ Gemini Agent${NC} - Not running"
    fi
    
    # Check Claude agent
    if pgrep -f "claude_loop.sh" > /dev/null; then
        local claude_pid=$(pgrep -f "claude_loop.sh")
        echo -e "${GREEN}✅ Claude Agent${NC} (PID: $claude_pid) - Running"
    else
        echo -e "${RED}❌ Claude Agent${NC} - Not running"
    fi
    
    echo ""
}

show_todo_status() {
    echo -e "${BLUE}📋 TODO Status${NC}"
    echo "─────────────────"
    
    if [ -f "$POSTBOX_DIR/todo.md" ]; then
        local pending_count=$(grep -c "^- \[ \]" "$POSTBOX_DIR/todo.md" 2>/dev/null || echo "0")
        echo -e "Pending TODOs: ${YELLOW}$pending_count${NC}"
        
        if [ "$pending_count" -gt 0 ]; then
            echo ""
            echo "📝 Recent TODO items:"
            grep "^- \[ \]" "$POSTBOX_DIR/todo.md" | head -3 | while read -r line; do
                echo -e "   ${YELLOW}•${NC} ${line#- [ ] }"
            done
        fi
    else
        echo -e "${RED}❌ TODO file not found${NC}"
    fi
    
    echo ""
}

show_completed_status() {
    echo -e "${BLUE}✅ Completed Status${NC}"
    echo "─────────────────────"
    
    if [ -f "$POSTBOX_DIR/completed-todos.md" ]; then
        local completed_count=$(grep -c "^## Completed:" "$POSTBOX_DIR/completed-todos.md" 2>/dev/null || echo "0")
        echo -e "Completed fixes: ${GREEN}$completed_count${NC}"
        
        if [ "$completed_count" -gt 0 ]; then
            echo ""
            echo "🎉 Recent completions:"
            grep "^## Completed:" "$POSTBOX_DIR/completed-todos.md" | tail -3 | while read -r line; do
                local timestamp=$(echo "$line" | sed 's/## Completed: //')
                echo -e "   ${GREEN}•${NC} Fix completed at $timestamp"
            done
        fi
    else
        echo -e "${RED}❌ Completed file not found${NC}"
    fi
    
    echo ""
}

show_recent_activity() {
    echo -e "${BLUE}📊 Recent Activity${NC}"
    echo "─────────────────────"
    
    # Show Gemini activity
    if [ -f "$POSTBOX_DIR/gemini.log" ]; then
        echo -e "${CYAN}Gemini Agent:${NC}"
        tail -3 "$POSTBOX_DIR/gemini.log" | while read -r line; do
            echo -e "   ${CYAN}•${NC} $line"
        done
    fi
    
    echo ""
    
    # Show Claude activity
    if [ -f "$POSTBOX_DIR/claude.log" ]; then
        echo -e "${CYAN}Claude Agent:${NC}"
        tail -3 "$POSTBOX_DIR/claude.log" | while read -r line; do
            echo -e "   ${CYAN}•${NC} $line"
        done
    fi
    
    echo ""
}

show_system_info() {
    echo -e "${BLUE}💻 System Info${NC}"
    echo "────────────────"
    
    # CPU usage
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' 2>/dev/null || echo "N/A")
    echo -e "CPU Usage: ${YELLOW}$cpu_usage%${NC}"
    
    # Memory usage
    local mem_usage=$(top -l 1 | grep "PhysMem" | awk '{print $2}' 2>/dev/null || echo "N/A")
    echo -e "Memory: ${YELLOW}$mem_usage${NC}"
    
    # Disk space
    local disk_usage=$(df -h . | tail -1 | awk '{print $5}' 2>/dev/null || echo "N/A")
    echo -e "Disk Usage: ${YELLOW}$disk_usage${NC}"
    
    echo ""
}

show_controls() {
    echo -e "${BLUE}🎛️  Controls${NC}"
    echo "─────────────"
    echo -e "${YELLOW}r${NC} - Refresh display"
    echo -e "${YELLOW}g${NC} - View Gemini logs"
    echo -e "${YELLOW}c${NC} - View Claude logs"
    echo -e "${YELLOW}t${NC} - View TODO file"
    echo -e "${YELLOW}f${NC} - View completed fixes"
    echo -e "${YELLOW}s${NC} - Start agents"
    echo -e "${YELLOW}k${NC} - Kill agents"
    echo -e "${YELLOW}q${NC} - Quit monitor"
    echo ""
}

start_agents() {
    echo "Starting agents..."
    
    # Start Gemini agent if not running
    if ! pgrep -f "gemini_loop.sh" > /dev/null; then
        cd "$WATCHER_DIR"
        nohup ./gemini_loop.sh > /dev/null 2>&1 &
        echo "✅ Gemini agent started"
    else
        echo "⚠️  Gemini agent already running"
    fi
    
    # Start Claude agent if not running
    if ! pgrep -f "claude_loop.sh" > /dev/null; then
        cd "$WATCHER_DIR"
        nohup ./claude_loop.sh > /dev/null 2>&1 &
        echo "✅ Claude agent started"
    else
        echo "⚠️  Claude agent already running"
    fi
    
    sleep 2
}

kill_agents() {
    echo "Stopping agents..."
    
    # Kill Gemini agent
    if pgrep -f "gemini_loop.sh" > /dev/null; then
        pkill -f "gemini_loop.sh"
        echo "✅ Gemini agent stopped"
    fi
    
    # Kill Claude agent
    if pgrep -f "claude_loop.sh" > /dev/null; then
        pkill -f "claude_loop.sh"
        echo "✅ Claude agent stopped"
    fi
    
    sleep 2
}

show_file() {
    local file="$1"
    local title="$2"
    
    clear_screen
    echo -e "${BLUE}📄 $title${NC}"
    echo "────────────────"
    
    if [ -f "$file" ]; then
        cat "$file"
    else
        echo -e "${RED}File not found: $file${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Press any key to return to monitor...${NC}"
    read -n 1 -s
}

# Interactive mode
interactive_mode() {
    while true; do
        clear_screen
        check_agent_status
        show_todo_status
        show_completed_status
        show_recent_activity
        show_system_info
        show_controls
        
        echo -n "Enter command: "
        read -n 1 -s input
        echo ""
        
        case "$input" in
            r|R)
                # Refresh - just continue the loop
                ;;
            g|G)
                show_file "$POSTBOX_DIR/gemini.log" "Gemini Agent Logs"
                ;;
            c|C)
                show_file "$POSTBOX_DIR/claude.log" "Claude Agent Logs"
                ;;
            t|T)
                show_file "$POSTBOX_DIR/todo.md" "TODO Items"
                ;;
            f|F)
                show_file "$POSTBOX_DIR/completed-todos.md" "Completed Fixes"
                ;;
            s|S)
                start_agents
                sleep 2
                ;;
            k|K)
                kill_agents
                sleep 2
                ;;
            q|Q)
                echo "Exiting monitor..."
                exit 0
                ;;
            *)
                echo "Invalid command"
                sleep 1
                ;;
        esac
    done
}

# Auto-refresh mode
auto_refresh_mode() {
    while true; do
        clear_screen
        check_agent_status
        show_todo_status
        show_completed_status
        show_recent_activity
        show_system_info
        
        echo -e "${YELLOW}Auto-refresh mode - Press Ctrl+C to exit${NC}"
        sleep 5
    done
}

# Main function
main() {
    # Check if in correct directory
    if [ ! -d "$POSTBOX_DIR" ]; then
        echo -e "${RED}Error: Run this script from the helpers/ directory${NC}"
        exit 1
    fi
    
    case "${1:-interactive}" in
        auto|watch)
            auto_refresh_mode
            ;;
        interactive|*)
            interactive_mode
            ;;
    esac
}

# Handle Ctrl+C gracefully
trap 'echo -e "\n${YELLOW}Monitor stopped${NC}"; exit 0' SIGINT

# Run main function
main "$@"