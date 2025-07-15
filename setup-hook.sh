#!/bin/bash

# Setup script for Claude Code Collaborative Agents Hook

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/claude-code-hook.sh"
SETTINGS_FILE="$SCRIPT_DIR/claude-settings.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔧 Setting up Claude Code Collaborative Agents Hook${NC}"
echo ""

# Make scripts executable
echo "1. Making scripts executable..."
chmod +x "$HOOK_SCRIPT"
chmod +x "$SCRIPT_DIR/watcher/gemini_loop.sh"
chmod +x "$SCRIPT_DIR/watcher/claude_loop.sh"
chmod +x "$SCRIPT_DIR/helpers/memory_manager.sh"

# Create necessary directories
echo "2. Creating directories..."
mkdir -p "$SCRIPT_DIR/postbox/memory"
mkdir -p "$SCRIPT_DIR/postbox/test_results"

# Update paths in settings file to be absolute
echo "3. Updating settings file with absolute paths..."
sed -i.bak "s|/Users/joshuafreeman/Desktop/agent_projects/collaborative-agents|$SCRIPT_DIR|g" "$SETTINGS_FILE"
rm -f "$SETTINGS_FILE.bak"

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1. Copy the settings to your Claude Code configuration:"
echo "   ${BLUE}cp $SETTINGS_FILE ~/.claude/settings.json${NC}"
echo ""
echo "   Or merge with existing settings:"
echo "   ${BLUE}# Add hooks section from claude-settings.json to your ~/.claude/settings.json${NC}"
echo ""
echo "2. Test the hook:"
echo "   ${BLUE}cd $SCRIPT_DIR/codebase${NC}"
echo "   ${BLUE}claude${NC}"
echo "   ${BLUE}> Edit any .py or .js file${NC}"
echo ""
echo "3. Monitor the collaborative agents:"
echo "   ${BLUE}tail -f $SCRIPT_DIR/postbox/hook.log${NC}"
echo "   ${BLUE}cat $SCRIPT_DIR/postbox/todo.md${NC}"
echo ""
echo -e "${YELLOW}⚠️  Requirements:${NC}"
echo "• Claude CLI must be installed and configured"
echo "• Gemini CLI must be installed (npm install -g @google/generative-ai-cli)"
echo "• jq must be installed for JSON processing"
echo ""
echo -e "${GREEN}🚀 Ready to use collaborative agents as a Claude Code hook!${NC}"