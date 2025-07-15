#!/bin/bash

# Test script for Claude Code Collaborative Agents Hook

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/claude-code-hook.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Claude Code Collaborative Agents Hook${NC}"
echo ""

# Test 1: Hook execution
echo -e "${YELLOW}Test 1: Hook execution${NC}"
if [ -x "$HOOK_SCRIPT" ]; then
    echo "✅ Hook script is executable"
else
    echo "❌ Hook script is not executable"
    exit 1
fi

# Test 2: Help functionality
echo -e "${YELLOW}Test 2: Help functionality${NC}"
if "$HOOK_SCRIPT" --help >/dev/null 2>&1; then
    echo "✅ Help command works"
else
    echo "❌ Help command failed"
    exit 1
fi

# Test 3: Create test code file
echo -e "${YELLOW}Test 3: Creating test code file${NC}"
mkdir -p "$SCRIPT_DIR/codebase"
cat > "$SCRIPT_DIR/codebase/test.py" << 'EOF'
def bad_function():
    if True:
        if True:
            if True:
                print("Too many nested ifs")
    return None

# Missing error handling
def risky_function():
    result = 10 / 0
    return result

# Performance issue
def slow_function():
    items = []
    for i in range(1000):
        for j in range(1000):
            items.append(i * j)
    return items
EOF

echo "✅ Test code file created"

# Test 4: Simulate hook trigger
echo -e "${YELLOW}Test 4: Simulating hook trigger${NC}"
echo '{"tool_name": "Edit", "working_directory": "'$SCRIPT_DIR'", "file_changes": ["test.py"]}' | "$HOOK_SCRIPT" PostToolUse

# Test 5: Check outputs
echo -e "${YELLOW}Test 5: Checking outputs${NC}"
if [ -f "$SCRIPT_DIR/postbox/hook.log" ]; then
    echo "✅ Hook log created"
else
    echo "❌ Hook log not created"
fi

if [ -f "$SCRIPT_DIR/postbox/hook_summary.md" ]; then
    echo "✅ Hook summary created"
    echo "📊 Summary contents:"
    cat "$SCRIPT_DIR/postbox/hook_summary.md"
else
    echo "❌ Hook summary not created"
fi

if [ -f "$SCRIPT_DIR/postbox/todo.md" ]; then
    echo "✅ TODO file created"
    todo_count=$(grep -c "^- \[ \]" "$SCRIPT_DIR/postbox/todo.md" 2>/dev/null || echo 0)
    echo "📋 Found $todo_count issues"
else
    echo "❌ TODO file not created"
fi

echo ""
echo -e "${GREEN}🎉 Hook test completed!${NC}"
echo ""
echo "Check the following files for results:"
echo "• $SCRIPT_DIR/postbox/hook.log"
echo "• $SCRIPT_DIR/postbox/hook_summary.md"
echo "• $SCRIPT_DIR/postbox/todo.md"
echo ""
echo -e "${BLUE}💡 To use with Claude Code:${NC}"
echo "1. Run: ./setup-hook.sh"
echo "2. Copy settings to ~/.claude/settings.json"
echo "3. Use Claude Code normally - hook will trigger automatically!"