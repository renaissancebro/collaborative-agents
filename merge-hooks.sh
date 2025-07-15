#!/bin/bash

# Script to safely merge collaborative agents hooks with existing Claude Code settings

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
BACKUP_SETTINGS="$HOME/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔗 Merging Collaborative Agents Hooks with Existing Settings${NC}"
echo ""

# Check if settings file exists
if [ ! -f "$CLAUDE_SETTINGS" ]; then
    echo -e "${RED}❌ Claude settings file not found: $CLAUDE_SETTINGS${NC}"
    echo "Creating new settings file..."
    mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
    cp "$SCRIPT_DIR/claude-settings.json" "$CLAUDE_SETTINGS"
    echo -e "${GREEN}✅ Settings file created${NC}"
    exit 0
fi

# Create backup
echo "1. Creating backup of existing settings..."
cp "$CLAUDE_SETTINGS" "$BACKUP_SETTINGS"
echo -e "${GREEN}✅ Backup created: $BACKUP_SETTINGS${NC}"

# Update the hook script path in the template
HOOK_SCRIPT_PATH="$SCRIPT_DIR/claude-code-hook.sh"

# Create the collaborative agents hooks to merge
cat > /tmp/collaborative_hooks.json << EOF
{
  "PostToolUse": [
    {
      "matcher": "Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOOK_SCRIPT_PATH PostToolUse",
          "description": "Trigger collaborative agents after file edits"
        }
      ]
    },
    {
      "matcher": "MultiEdit", 
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOOK_SCRIPT_PATH PostToolUse",
          "description": "Trigger collaborative agents after multi-file edits"
        }
      ]
    },
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command", 
          "command": "bash $HOOK_SCRIPT_PATH PostToolUse",
          "description": "Trigger collaborative agents after writing files"
        }
      ]
    },
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOOK_SCRIPT_PATH PostToolUse",
          "description": "Trigger collaborative agents after bash commands"
        }
      ]
    }
  ],
  "Stop": [
    {
      "matcher": "collaborative-agents",
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOOK_SCRIPT_PATH Stop",
          "description": "Generate collaborative agents summary when Claude stops"
        }
      ]
    }
  ]
}
EOF

echo "2. Merging hooks with existing configuration..."

# Use jq to merge the hooks
jq --slurpfile new_hooks /tmp/collaborative_hooks.json '
  # Add new PostToolUse hooks to existing ones
  .hooks.PostToolUse = (.hooks.PostToolUse // []) + $new_hooks[0].PostToolUse |
  
  # Add new Stop hooks to existing ones  
  .hooks.Stop = (.hooks.Stop // []) + $new_hooks[0].Stop |
  
  # Add collaborative_agents config section
  .collaborative_agents = {
    "enabled": true,
    "auto_fix": true,
    "gemini_model": "gemini-1.5-flash",
    "scan_file_limit": 10,
    "memory_enabled": true
  }
' "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp" && mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"

# Cleanup
rm -f /tmp/collaborative_hooks.json

echo -e "${GREEN}✅ Hooks merged successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Summary of changes:${NC}"
echo "• Added 4 new PostToolUse hooks for collaborative agents"
echo "• Added 1 new Stop hook for session summaries"  
echo "• Added collaborative_agents configuration section"
echo "• Your existing hooks are preserved"
echo ""
echo -e "${BLUE}🔍 Review the merged configuration:${NC}"
echo "   ${BLUE}cat $CLAUDE_SETTINGS${NC}"
echo ""
echo -e "${BLUE}📂 Your existing hooks are still active:${NC}"
jq -r '.hooks | to_entries[] | "• \(.key): \(.value | length) hook(s)"' "$CLAUDE_SETTINGS"
echo ""
echo -e "${GREEN}🚀 Collaborative agents are now integrated with your existing hooks!${NC}"
echo ""
echo -e "${YELLOW}⚠️  If something goes wrong, restore from backup:${NC}"
echo "   ${BLUE}cp $BACKUP_SETTINGS $CLAUDE_SETTINGS${NC}"