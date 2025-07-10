#!/bin/bash

# Langfuse Integration for Collaborative Agents
# Sends session data, fixes, and insights to Langfuse for advanced analytics

set -euo pipefail

# Configuration
MEMORY_DIR="../postbox/memory"
LANGFUSE_API_URL="${LANGFUSE_API_URL:-https://cloud.langfuse.com}"
LANGFUSE_PUBLIC_KEY="${LANGFUSE_PUBLIC_KEY:-}"
LANGFUSE_SECRET_KEY="${LANGFUSE_SECRET_KEY:-}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[LANGFUSE]${NC} $1"
}

success() {
    echo -e "${GREEN}[LANGFUSE]${NC} $1"
}

error() {
    echo -e "${RED}[LANGFUSE]${NC} $1"
}

# Check Langfuse configuration
check_langfuse_config() {
    if [ -z "$LANGFUSE_PUBLIC_KEY" ] || [ -z "$LANGFUSE_SECRET_KEY" ]; then
        error "Langfuse keys not configured. Set LANGFUSE_PUBLIC_KEY and LANGFUSE_SECRET_KEY"
        echo "Add to your ~/.zshrc or .env file:"
        echo "export LANGFUSE_PUBLIC_KEY='your_public_key'"
        echo "export LANGFUSE_SECRET_KEY='your_secret_key'"
        return 1
    fi
}

# Send fix event to Langfuse
send_fix_to_langfuse() {
    local trace_id="$1"
    local fix_data="$2"
    
    info "Sending fix data to Langfuse..."
    
    # Extract data from JSON
    local status=$(echo "$fix_data" | jq -r '.status')
    local category=$(echo "$fix_data" | jq -r '.category')
    local file_path=$(echo "$fix_data" | jq -r '.file_path')
    local duration=$(echo "$fix_data" | jq -r '.duration')
    local reasoning=$(echo "$fix_data" | jq -r '.reasoning')
    
    # Create Langfuse event
    local event_data=$(cat << EOF
{
    "name": "collaborative_agent_fix",
    "traceId": "$trace_id",
    "input": {
        "todo_item": $(echo "$fix_data" | jq '.todo_item'),
        "file_path": "$file_path",
        "category": "$category"
    },
    "output": {
        "fix_applied": $(echo "$fix_data" | jq '.fix_applied'),
        "status": "$status",
        "test_results": $(echo "$fix_data" | jq '.test_results')
    },
    "metadata": {
        "agent": "claude",
        "duration_seconds": $duration,
        "system": "collaborative_agents",
        "file_type": "${file_path##*.}",
        "reasoning": "$reasoning"
    },
    "level": "$([ "$status" = "success" ] && echo "DEFAULT" || echo "WARNING")",
    "statusMessage": "$status"
}
EOF
)
    
    # Send to Langfuse
    curl -s -X POST "$LANGFUSE_API_URL/api/public/events" \
        -H "Authorization: Basic $(echo -n "${LANGFUSE_PUBLIC_KEY}:${LANGFUSE_SECRET_KEY}" | base64)" \
        -H "Content-Type: application/json" \
        -d "$event_data" > /dev/null
    
    success "Fix event sent to Langfuse (trace: $trace_id)"
}

# Send session analytics to Langfuse
send_session_analytics() {
    local session_id="$1"
    
    if [ ! -f "$MEMORY_DIR/analytics.json" ]; then
        error "No analytics data found"
        return 1
    fi
    
    info "Sending session analytics to Langfuse..."
    
    local analytics=$(cat "$MEMORY_DIR/analytics.json")
    
    # Create session trace
    local trace_data=$(cat << EOF
{
    "name": "collaborative_agent_session",
    "id": "$session_id",
    "input": {
        "session_start": $(echo "$analytics" | jq '.session_start'),
        "system": "collaborative_agents"
    },
    "output": {
        "total_fixes_attempted": $(echo "$analytics" | jq '.total_fixes_attempted'),
        "successful_fixes": $(echo "$analytics" | jq '.successful_fixes'),
        "failed_fixes": $(echo "$analytics" | jq '.failed_fixes'),
        "fix_success_rate": $(echo "$analytics" | jq '.fix_success_rate'),
        "files_modified": $(echo "$analytics" | jq '.files_modified'),
        "fix_categories": $(echo "$analytics" | jq '.fix_categories')
    },
    "metadata": {
        "session_duration": "$(date +%s)",
        "agents": ["gemini", "claude"],
        "features": ["auto_revert", "testing", "memory"]
    }
}
EOF
)
    
    # Send to Langfuse
    curl -s -X POST "$LANGFUSE_API_URL/api/public/traces" \
        -H "Authorization: Basic $(echo -n "${LANGFUSE_PUBLIC_KEY}:${LANGFUSE_SECRET_KEY}" | base64)" \
        -H "Content-Type: application/json" \
        -d "$trace_data" > /dev/null
    
    success "Session analytics sent to Langfuse (session: $session_id)"
}

# Send insights to Langfuse
send_insights_to_langfuse() {
    local session_id="$1"
    
    if [ ! -f "$MEMORY_DIR/insights.md" ]; then
        # Generate insights first
        ../helpers/memory_manager.sh insights
    fi
    
    info "Sending insights to Langfuse..."
    
    local insights_content=$(cat "$MEMORY_DIR/insights.md")
    
    # Create insights event
    local insights_data=$(cat << EOF
{
    "name": "session_insights_generated",
    "traceId": "$session_id",
    "input": {
        "analytics_data": $(cat "$MEMORY_DIR/analytics.json" 2>/dev/null || echo '{}'),
        "patterns_data": $(cat "$MEMORY_DIR/patterns.json" 2>/dev/null || echo '{}')
    },
    "output": {
        "insights": $(echo "$insights_content" | jq -Rs .),
        "insights_length": ${#insights_content}
    },
    "metadata": {
        "insight_type": "session_analysis",
        "generated_by": "collaborative_agents",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
}
EOF
)
    
    # Send to Langfuse
    curl -s -X POST "$LANGFUSE_API_URL/api/public/events" \
        -H "Authorization: Basic $(echo -n "${LANGFUSE_PUBLIC_KEY}:${LANGFUSE_SECRET_KEY}" | base64)" \
        -H "Content-Type: application/json" \
        -d "$insights_data" > /dev/null
    
    success "Insights sent to Langfuse"
}

# Monitor and sync continuously
start_langfuse_sync() {
    local session_id="session_$(date +%s)"
    
    info "Starting continuous Langfuse sync (session: $session_id)"
    
    # Send initial session
    send_session_analytics "$session_id"
    
    # Monitor for new fixes
    local last_check=$(date +%s)
    
    while true; do
        if [ -f "$MEMORY_DIR/session_log.md" ]; then
            # Check if session log was modified
            local log_mod_time=$(stat -f %m "$MEMORY_DIR/session_log.md" 2>/dev/null || echo 0)
            
            if [ "$log_mod_time" -gt "$last_check" ]; then
                info "New activity detected, syncing to Langfuse..."
                
                # Send updated analytics
                send_session_analytics "$session_id"
                
                # Send insights if available
                if [ -f "$MEMORY_DIR/insights.md" ]; then
                    send_insights_to_langfuse "$session_id"
                fi
                
                last_check=$(date +%s)
            fi
        fi
        
        sleep 30  # Check every 30 seconds
    done
}

# One-time sync
sync_current_session() {
    local session_id="session_$(date +%s)"
    
    info "Performing one-time sync to Langfuse..."
    
    # Send session analytics
    send_session_analytics "$session_id"
    
    # Send insights
    send_insights_to_langfuse "$session_id"
    
    success "Sync completed!"
}

# Main function
main() {
    check_langfuse_config || exit 1
    
    case "${1:-sync}" in
        sync)
            sync_current_session
            ;;
        monitor)
            start_langfuse_sync
            ;;
        analytics)
            send_session_analytics "session_$(date +%s)"
            ;;
        insights)
            send_insights_to_langfuse "session_$(date +%s)"
            ;;
        --help|-h)
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  sync       One-time sync of current session (default)"
            echo "  monitor    Continuous monitoring and sync"
            echo "  analytics  Send analytics only"
            echo "  insights   Send insights only"
            echo "  --help     Show this help"
            echo ""
            echo "Environment variables:"
            echo "  LANGFUSE_PUBLIC_KEY   Your Langfuse public key"
            echo "  LANGFUSE_SECRET_KEY   Your Langfuse secret key"
            echo "  LANGFUSE_API_URL      Langfuse API URL (default: https://cloud.langfuse.com)"
            ;;
        *)
            error "Unknown command: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"