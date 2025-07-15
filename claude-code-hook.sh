#!/bin/bash

# Claude Code Hook - Collaborative Agents Integration
# Triggers Gemini analysis after code changes and enables collaborative fixing

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_DIR="$SCRIPT_DIR/codebase"
WATCHER_DIR="$SCRIPT_DIR/watcher"
POSTBOX_DIR="$SCRIPT_DIR/postbox"
HOOK_LOG="$POSTBOX_DIR/hook.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK: $1" | tee -a "$HOOK_LOG"
}

info() {
    echo -e "${BLUE}[HOOK]${NC} $1" | tee -a "$HOOK_LOG"
}

success() {
    echo -e "${GREEN}[HOOK]${NC} $1" | tee -a "$HOOK_LOG"
}

warn() {
    echo -e "${YELLOW}[HOOK]${NC} $1" | tee -a "$HOOK_LOG"
}

error() {
    echo -e "${RED}[HOOK]${NC} $1" | tee -a "$HOOK_LOG"
}

# Parse hook input from Claude Code
parse_hook_input() {
    local tool_name=""
    local tool_args=""
    local working_dir=""
    local file_changes=""
    
    # Read JSON input from Claude Code
    if [ -t 0 ]; then
        # No input from stdin, get from environment or args
        tool_name="${CLAUDE_TOOL_NAME:-unknown}"
        working_dir="${PWD}"
    else
        # Parse JSON input
        local input=$(cat)
        tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
        working_dir=$(echo "$input" | jq -r '.working_directory // "."' 2>/dev/null || echo ".")
        file_changes=$(echo "$input" | jq -r '.file_changes[]? // empty' 2>/dev/null || echo "")
    fi
    
    echo "$tool_name|$working_dir|$file_changes"
}

# Check if we should trigger collaborative analysis
should_trigger_analysis() {
    local tool_name="$1"
    local working_dir="$2"
    local file_changes="$3"
    
    # Trigger on file modifications
    case "$tool_name" in
        "Edit"|"MultiEdit"|"Write"|"NotebookEdit")
            return 0
            ;;
        "Bash")
            # Check if bash command might have modified code files
            if [[ "$CLAUDE_COMMAND" =~ (git|npm|pip|yarn|make) ]]; then
                return 0
            fi
            ;;
    esac
    
    # Also trigger if we detect code file changes in the directory
    if [ -n "$file_changes" ]; then
        if echo "$file_changes" | grep -qE '\.(py|js|ts|jsx|tsx)$'; then
            return 0
        fi
    fi
    
    return 1
}

# Start collaborative analysis
start_collaborative_analysis() {
    local trigger_reason="$1"
    
    info "🤝 Starting collaborative analysis (trigger: $trigger_reason)"
    
    # Ensure directories exist
    mkdir -p "$POSTBOX_DIR" "$CODEBASE_DIR"
    
    # Initialize memory system if needed
    if [ -x "$SCRIPT_DIR/helpers/memory_manager.sh" ]; then
        "$SCRIPT_DIR/helpers/memory_manager.sh" init >/dev/null 2>&1 || true
    fi
    
    # Start Gemini analysis in background
    if [ -x "$WATCHER_DIR/gemini_loop.sh" ]; then
        info "🔍 Triggering Gemini code analysis..."
        
        # Run one-shot analysis instead of continuous loop
        (
            cd "$WATCHER_DIR"
            # Set the correct codebase path for the hook context
            export CODEBASE_DIR="$SCRIPT_DIR/codebase"
            # Modified version for hook - single scan
            timeout 30 ./gemini_loop.sh scan-once 2>/dev/null || true
        ) &
        local gemini_pid=$!
        
        # Wait briefly for analysis to complete
        sleep 5
        
        # Check if TODO items were generated
        if [ -f "$POSTBOX_DIR/todo.md" ]; then
            local todo_count=$(grep -c "^- \[ \]" "$POSTBOX_DIR/todo.md" 2>/dev/null || echo "0")
            if [ "$todo_count" -gt 0 ] 2>/dev/null; then
                success "📋 Found $todo_count issues to fix"
                
                # Optionally start Claude fixing loop
                if command -v claude >/dev/null 2>&1; then
                    info "🔧 Starting Claude auto-fix process..."
                    
                    # Run single fix attempt
                    (
                        cd "$WATCHER_DIR"
                        ./claude_loop.sh fix-once 2>/dev/null &
                    )
                    
                    success "🚀 Collaborative fixing started"
                else
                    warn "Claude CLI not found - skipping auto-fix"
                fi
            else
                info "✅ No issues found in code analysis"
            fi
        fi
        
        # Clean up
        kill "$gemini_pid" 2>/dev/null || true
    else
        error "Gemini loop script not found or not executable"
    fi
}

# Generate summary for user
generate_summary() {
    local summary_file="$POSTBOX_DIR/hook_summary.md"
    
    cat > "$summary_file" << EOF
# Collaborative Agents Hook Summary

**Triggered:** $(date '+%Y-%m-%d %H:%M:%S')
**Working Directory:** $PWD

## Analysis Results

EOF
    
    if [ -f "$POSTBOX_DIR/todo.md" ]; then
        local todo_count=$(grep -c "^- \[ \]" "$POSTBOX_DIR/todo.md" 2>/dev/null || echo "0")
        echo "- **Issues Found:** $todo_count" >> "$summary_file"
        
        if [ "$todo_count" -gt 0 ] 2>/dev/null; then
            echo "- **Status:** Auto-fixing in progress" >> "$summary_file"
            echo "" >> "$summary_file"
            echo "## Issues Detected" >> "$summary_file"
            echo "" >> "$summary_file"
            grep "^- \[ \]" "$POSTBOX_DIR/todo.md" >> "$summary_file" 2>/dev/null || true
        else
            echo "- **Status:** No issues detected" >> "$summary_file"
        fi
    else
        echo "- **Issues Found:** 0" >> "$summary_file"
        echo "- **Status:** Analysis not completed" >> "$summary_file"
    fi
    
    echo "" >> "$summary_file"
    echo "## Memory & Analytics" >> "$summary_file"
    echo "" >> "$summary_file"
    
    if [ -f "$POSTBOX_DIR/memory/analytics.json" ]; then
        local total_fixes=$(jq -r '.total_fixes_attempted // 0' "$POSTBOX_DIR/memory/analytics.json")
        local success_rate=$(jq -r '.fix_success_rate // 0' "$POSTBOX_DIR/memory/analytics.json")
        echo "- **Total Fixes Attempted:** $total_fixes" >> "$summary_file"
        echo "- **Success Rate:** $success_rate%" >> "$summary_file"
    else
        echo "- **Session:** First run - no historical data" >> "$summary_file"
    fi
    
    success "📊 Summary generated: $summary_file"
}

# Main hook logic
main() {
    local hook_event="${1:-PostToolUse}"
    
    log "Hook triggered: $hook_event"
    
    # Parse input from Claude Code
    local parsed_input=$(parse_hook_input)
    local tool_name=$(echo "$parsed_input" | cut -d'|' -f1)
    local working_dir=$(echo "$parsed_input" | cut -d'|' -f2)
    local file_changes=$(echo "$parsed_input" | cut -d'|' -f3)
    
    info "Tool: $tool_name, Dir: $working_dir"
    
    # Check if we should trigger analysis
    if should_trigger_analysis "$tool_name" "$working_dir" "$file_changes"; then
        start_collaborative_analysis "$tool_name"
        generate_summary
        
        # Provide feedback to user
        if [ -f "$POSTBOX_DIR/hook_summary.md" ]; then
            echo ""
            echo "🤝 Collaborative Agents Analysis Complete"
            echo "📊 Summary: $POSTBOX_DIR/hook_summary.md"
            echo "📋 Issues: $POSTBOX_DIR/todo.md"
            echo "🧠 Memory: $POSTBOX_DIR/memory/"
        fi
    else
        log "No trigger conditions met for tool: $tool_name"
    fi
}

# Handle different hook events
case "${1:-PostToolUse}" in
    "PostToolUse")
        main "PostToolUse"
        ;;
    "Stop")
        main "Stop"
        ;;
    "PreToolUse")
        # For PreToolUse, we might want to check previous patterns
        log "PreToolUse hook - checking patterns..."
        ;;
    "--help"|"-h")
        echo "Claude Code Collaborative Agents Hook"
        echo ""
        echo "Usage: $0 [event_type]"
        echo ""
        echo "Events:"
        echo "  PostToolUse  - After tool execution (default)"
        echo "  Stop         - When Claude finishes responding"
        echo "  PreToolUse   - Before tool execution"
        echo ""
        echo "This hook integrates with the collaborative agents system to:"
        echo "- Trigger Gemini analysis after code changes"
        echo "- Start Claude auto-fixing for detected issues"
        echo "- Maintain session memory and analytics"
        ;;
    *)
        warn "Unknown hook event: $1"
        ;;
esac

exit 0