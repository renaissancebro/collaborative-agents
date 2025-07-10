#!/bin/bash

# Memory Manager - Session logging and analytics for collaborative agents
# Tracks fixes, reasoning, breakage patterns, and provides insights

set -euo pipefail

# Configuration
POSTBOX_DIR="../postbox"
MEMORY_DIR="$POSTBOX_DIR/memory"
SESSION_LOG="$MEMORY_DIR/session_log.md"
ANALYTICS_FILE="$MEMORY_DIR/analytics.json"
PATTERNS_FILE="$MEMORY_DIR/patterns.json"
LOG_FILE="$POSTBOX_DIR/memory_manager.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

# Initialize memory system
init_memory() {
    mkdir -p "$MEMORY_DIR"
    touch "$LOG_FILE"
    
    # Initialize session log
    if [ ! -f "$SESSION_LOG" ]; then
        cat > "$SESSION_LOG" << EOF
# Collaborative Agents Session Log

## Session Overview
- **Started:** $(date '+%Y-%m-%d %H:%M:%S')
- **System:** Dual-agent collaborative coding system
- **Agents:** Gemini (Detection) + Claude (Fixes)

## Session Statistics
- **Total Fixes Attempted:** 0
- **Successful Fixes:** 0
- **Failed/Reverted Fixes:** 0
- **Files Modified:** 0
- **Test Runs:** 0

---

## Fix History

EOF
    fi
    
    # Initialize analytics
    if [ ! -f "$ANALYTICS_FILE" ]; then
        cat > "$ANALYTICS_FILE" << 'EOF'
{
  "session_start": "",
  "total_fixes_attempted": 0,
  "successful_fixes": 0,
  "failed_fixes": 0,
  "reverted_fixes": 0,
  "files_modified": [],
  "common_issues": {},
  "fix_success_rate": 0.0,
  "avg_fix_time": 0,
  "test_pass_rate": 0.0,
  "most_problematic_files": [],
  "fix_categories": {
    "security": 0,
    "performance": 0,
    "code_smell": 0,
    "syntax": 0,
    "logic": 0,
    "style": 0
  },
  "breakage_patterns": [],
  "learning_insights": []
}
EOF
    fi
    
    # Initialize patterns tracking
    if [ ! -f "$PATTERNS_FILE" ]; then
        cat > "$PATTERNS_FILE" << 'EOF'
{
  "failure_patterns": [],
  "success_patterns": [],
  "file_type_success_rates": {},
  "common_breakage_causes": {},
  "fix_type_effectiveness": {},
  "time_based_patterns": {},
  "recurring_issues": []
}
EOF
    fi
    
    # Update session start time
    jq --arg start_time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.session_start = $start_time' "$ANALYTICS_FILE" > "$ANALYTICS_FILE.tmp" && mv "$ANALYTICS_FILE.tmp" "$ANALYTICS_FILE"
}

# Log a fix attempt (successful or failed)
log_fix_attempt() {
    local todo_item="$1"
    local file_path="$2"
    local fix_applied="$3"
    local reasoning="$4"
    local status="$5"  # "success", "failed", "reverted"
    local test_results="$6"
    local duration="${7:-0}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local session_id=$(date +%s)_$$
    
    info "📝 Logging fix attempt: $status"
    
    # Extract fix category from TODO item
    local fix_category="unknown"
    case "$todo_item" in
        *"security"*|*"password"*|*"vulnerability"*) fix_category="security" ;;
        *"performance"*|*"slow"*|*"optimization"*) fix_category="performance" ;;
        *"code smell"*|*"refactor"*|*"clean"*) fix_category="code_smell" ;;
        *"syntax"*|*"compile"*|*"parse"*) fix_category="syntax" ;;
        *"logic"*|*"algorithm"*|*"bug"*) fix_category="logic" ;;
        *"style"*|*"format"*|*"lint"*) fix_category="style" ;;
    esac
    
    # Add to session log
    {
        echo "### Fix #$session_id - $status"
        echo ""
        echo "**Timestamp:** $timestamp"
        echo "**File:** \`$(basename "$file_path")\`"
        echo "**Category:** $fix_category"
        echo "**Duration:** ${duration}s"
        echo ""
        echo "**Original Issue:**"
        echo "> $todo_item"
        echo ""
        echo "**Fix Applied:**"
        echo "> $fix_applied"
        echo ""
        echo "**Claude's Reasoning:**"
        echo "\`\`\`"
        echo "$reasoning"
        echo "\`\`\`"
        echo ""
        echo "**Test Results:**"
        if [ "$test_results" = "passed" ]; then
            echo "✅ All tests passed"
        elif [ "$test_results" = "failed" ]; then
            echo "❌ Tests failed - changes reverted"
        else
            echo "⚠️ $test_results"
        fi
        echo ""
        echo "**Status:** "
        case "$status" in
            "success") echo "🎉 **SUCCESSFUL** - Fix applied and working" ;;
            "failed") echo "💥 **FAILED** - Fix couldn't be applied" ;;
            "reverted") echo "🔄 **REVERTED** - Fix broke tests, auto-reverted" ;;
        esac
        echo ""
        echo "---"
        echo ""
    } >> "$SESSION_LOG"
    
    # Update analytics
    update_analytics "$file_path" "$fix_category" "$status" "$duration" "$test_results"
    
    # Update patterns
    update_patterns "$todo_item" "$file_path" "$fix_category" "$status" "$reasoning"
    
    # Update session statistics in log header
    update_session_stats
}

# Update analytics data
update_analytics() {
    local file_path="$1"
    local fix_category="$2" 
    local status="$3"
    local duration="$4"
    local test_results="$5"
    
    local temp_file="$ANALYTICS_FILE.tmp"
    
    # Update counters and data
    jq --arg file_path "$file_path" \
       --arg fix_category "$fix_category" \
       --arg status "$status" \
       --argjson duration "$duration" \
       --arg test_results "$test_results" '
    .total_fixes_attempted += 1 |
    (if $status == "success" then .successful_fixes += 1 else . end) |
    (if $status == "failed" then .failed_fixes += 1 else . end) |
    (if $status == "reverted" then .reverted_fixes += 1 else . end) |
    .files_modified |= (. + [$file_path] | unique) |
    .fix_categories[$fix_category] += 1 |
    .fix_success_rate = (.successful_fixes / .total_fixes_attempted * 100 | floor) |
    (if $test_results == "passed" then .test_pass_rate = .test_pass_rate else . end)
    ' "$ANALYTICS_FILE" > "$temp_file" && mv "$temp_file" "$ANALYTICS_FILE"
}

# Update pattern recognition
update_patterns() {
    local todo_item="$1"
    local file_path="$2"
    local fix_category="$3"
    local status="$4"
    local reasoning="$5"
    
    local file_ext="${file_path##*.}"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    local pattern_entry="{
        \"timestamp\": \"$timestamp\",
        \"file_type\": \"$file_ext\", 
        \"category\": \"$fix_category\",
        \"status\": \"$status\",
        \"issue_keywords\": \"$todo_item\",
        \"reasoning_snippet\": \"$(echo "$reasoning" | head -c 200)...\"
    }"
    
    local temp_file="$PATTERNS_FILE.tmp"
    
    if [ "$status" = "success" ]; then
        jq --argjson entry "$pattern_entry" '.success_patterns += [$entry]' "$PATTERNS_FILE" > "$temp_file"
    else
        jq --argjson entry "$pattern_entry" '.failure_patterns += [$entry]' "$PATTERNS_FILE" > "$temp_file"
    fi
    
    mv "$temp_file" "$PATTERNS_FILE"
}

# Update session statistics in the log header
update_session_stats() {
    if [ ! -f "$ANALYTICS_FILE" ]; then
        return
    fi
    
    local total_attempts=$(jq -r '.total_fixes_attempted' "$ANALYTICS_FILE")
    local successful=$(jq -r '.successful_fixes' "$ANALYTICS_FILE")
    local failed=$(jq -r '.failed_fixes' "$ANALYTICS_FILE")
    local reverted=$(jq -r '.reverted_fixes' "$ANALYTICS_FILE")
    local files_count=$(jq -r '.files_modified | length' "$ANALYTICS_FILE")
    local success_rate=$(jq -r '.fix_success_rate' "$ANALYTICS_FILE")
    
    # Update the stats section in session log
    sed -i.bak '/^## Session Statistics/,/^---/{
        /^- \*\*Total Fixes Attempted:\*\*/c\
- **Total Fixes Attempted:** '$total_attempts'
        /^- \*\*Successful Fixes:\*\*/c\
- **Successful Fixes:** '$successful'
        /^- \*\*Failed\/Reverted Fixes:\*\*/c\
- **Failed/Reverted Fixes:** '$((failed + reverted))'
        /^- \*\*Files Modified:\*\*/c\
- **Files Modified:** '$files_count'
        /^- \*\*Test Runs:\*\*/c\
- **Test Runs:** '$total_attempts'
    }' "$SESSION_LOG"
    
    rm -f "${SESSION_LOG}.bak"
}

# Generate insights and learning patterns
generate_insights() {
    info "🧠 Generating session insights..."
    
    local insights_file="$MEMORY_DIR/insights.md"
    
    cat > "$insights_file" << EOF
# Session Insights & Learning

Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Key Metrics
EOF
    
    if [ -f "$ANALYTICS_FILE" ]; then
        local total_attempts=$(jq -r '.total_fixes_attempted' "$ANALYTICS_FILE")
        local success_rate=$(jq -r '.fix_success_rate' "$ANALYTICS_FILE")
        local most_common_category=$(jq -r '.fix_categories | to_entries | max_by(.value) | .key' "$ANALYTICS_FILE")
        
        cat >> "$insights_file" << EOF

- **Total Fix Attempts:** $total_attempts
- **Success Rate:** $success_rate%
- **Most Common Issue Type:** $most_common_category
- **Files Modified:** $(jq -r '.files_modified | length' "$ANALYTICS_FILE")

## Top Issue Categories
EOF
        
        jq -r '.fix_categories | to_entries | sort_by(.value) | reverse | .[] | "- **\(.key):** \(.value) fixes"' "$ANALYTICS_FILE" >> "$insights_file"
    fi
    
    # Analyze patterns
    if [ -f "$PATTERNS_FILE" ]; then
        echo "" >> "$insights_file"
        echo "## Pattern Analysis" >> "$insights_file"
        echo "" >> "$insights_file"
        
        local success_count=$(jq -r '.success_patterns | length' "$PATTERNS_FILE")
        local failure_count=$(jq -r '.failure_patterns | length' "$PATTERNS_FILE")
        
        echo "- **Successful Pattern Count:** $success_count" >> "$insights_file"
        echo "- **Failure Pattern Count:** $failure_count" >> "$insights_file"
        echo "" >> "$insights_file"
        
        # Most problematic file types
        echo "### File Type Success Rates" >> "$insights_file"
        echo "" >> "$insights_file"
        
        jq -r '.success_patterns + .failure_patterns | group_by(.file_type) | .[] | 
               {file_type: .[0].file_type, 
                total: length, 
                successes: [.[] | select(.status == "success")] | length} |
               "- **\(.file_type):** \(.successes)/\(.total) (\((.successes/.total*100|floor))%)"' "$PATTERNS_FILE" >> "$insights_file"
    fi
    
    # Add recommendations
    cat >> "$insights_file" << 'EOF'

## Recommendations

### Based on Current Patterns:

1. **High-Success Categories:** Focus Gemini detection on categories with high fix success rates
2. **Problematic Areas:** Files/patterns with low success rates may need manual review
3. **Testing Effectiveness:** Auto-revert feature is protecting code quality
4. **Agent Collaboration:** Review failed patterns to improve Gemini detection accuracy

### Continuous Improvement:

- Monitor recurring failure patterns
- Adjust prompts based on successful reasoning patterns  
- Focus on file types with consistent success rates
- Use breakage patterns to enhance testing coverage

EOF
    
    success "Insights generated: $insights_file"
}

# Create memory summary for monitoring
create_memory_summary() {
    local summary_file="$MEMORY_DIR/memory_summary.json"
    
    if [ -f "$ANALYTICS_FILE" ]; then
        local total_attempts=$(jq -r '.total_fixes_attempted' "$ANALYTICS_FILE")
        local success_rate=$(jq -r '.fix_success_rate' "$ANALYTICS_FILE")
        local files_modified=$(jq -r '.files_modified | length' "$ANALYTICS_FILE")
        
        cat > "$summary_file" << EOF
{
  "total_attempts": $total_attempts,
  "success_rate": $success_rate,
  "files_modified": $files_modified,
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_active": true,
  "memory_files": {
    "session_log": "$SESSION_LOG",
    "analytics": "$ANALYTICS_FILE", 
    "patterns": "$PATTERNS_FILE",
    "insights": "$MEMORY_DIR/insights.md"
  }
}
EOF
    fi
}

# Archive session when done
archive_session() {
    local archive_dir="$MEMORY_DIR/archive"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    
    mkdir -p "$archive_dir"
    
    # Archive current session
    cp "$SESSION_LOG" "$archive_dir/session_log_$timestamp.md"
    cp "$ANALYTICS_FILE" "$archive_dir/analytics_$timestamp.json"
    cp "$PATTERNS_FILE" "$archive_dir/patterns_$timestamp.json"
    
    success "Session archived to $archive_dir"
    
    # Reset for new session
    rm -f "$SESSION_LOG" "$ANALYTICS_FILE" "$PATTERNS_FILE"
    init_memory
}

# Main function
main() {
    case "${1:-init}" in
        init)
            init_memory
            info "Memory system initialized"
            ;;
        log-fix)
            if [ $# -lt 6 ]; then
                error "Usage: $0 log-fix <todo_item> <file_path> <fix_applied> <reasoning> <status> <test_results> [duration]"
                exit 1
            fi
            log_fix_attempt "$2" "$3" "$4" "$5" "$6" "$7" "${8:-0}"
            create_memory_summary
            ;;
        insights)
            generate_insights
            ;;
        summary)
            create_memory_summary
            ;;
        archive)
            archive_session
            ;;
        stats)
            if [ -f "$ANALYTICS_FILE" ]; then
                echo "=== Session Statistics ==="
                jq -r '"Total Attempts: " + (.total_fixes_attempted | tostring) + 
                       "\nSuccessful: " + (.successful_fixes | tostring) +
                       "\nFailed: " + (.failed_fixes | tostring) +
                       "\nReverted: " + (.reverted_fixes | tostring) +
                       "\nSuccess Rate: " + (.fix_success_rate | tostring) + "%"' "$ANALYTICS_FILE"
            else
                echo "No analytics data available"
            fi
            ;;
        patterns)
            if [ -f "$PATTERNS_FILE" ]; then
                echo "=== Success/Failure Patterns ==="
                echo "Success patterns: $(jq -r '.success_patterns | length' "$PATTERNS_FILE")"
                echo "Failure patterns: $(jq -r '.failure_patterns | length' "$PATTERNS_FILE")"
            else
                echo "No pattern data available"
            fi
            ;;
        --help|-h)
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  init                    Initialize memory system"
            echo "  log-fix <args>          Log a fix attempt"
            echo "  insights                Generate session insights"
            echo "  summary                 Create memory summary"
            echo "  archive                 Archive current session"
            echo "  stats                   Show session statistics"
            echo "  patterns                Show pattern analysis"
            echo "  --help                  Show this help"
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