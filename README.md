# Collaborative Agents System

A dual-agent workflow system with **comprehensive self-testing, auto-revert, and session memory** capabilities:
- **Gemini Agent** detects code issues and creates TODOs
- **Claude Agent** applies fixes with automatic testing and rollback
- **Smart Testing** runs before/after comparisons and reverts failed fixes
- **Session Memory** tracks all fixes, reasoning, and breakage patterns
- **Comprehensive Monitoring** with analytics and insights
- **🆕 Claude Code Hook Integration** - Works seamlessly as a Claude Code hook

## 🚀 Quick Start

### Option 1: Claude Code Hook Integration (Recommended)
```bash
# Setup as Claude Code hook
./setup-hook.sh
./merge-hooks.sh

# Test the integration
./test-hook.sh

# Now use Claude Code normally - collaborative agents run automatically!
claude
```

### Option 2: Standalone System
```bash
# Traditional setup
cd helpers
./setup.sh

# Run manually
# Terminal 1 - Gemini Agent
cd watcher && ./gemini_loop.sh

# Terminal 2 - Claude Agent  
cd watcher && ./claude_loop.sh

# Terminal 3 - Monitor Dashboard
cd helpers && ./monitor.sh
```

## 🎯 **NEW: Claude Code Hook Integration**

### How It Works
The collaborative agents now integrate seamlessly with Claude Code as hooks:

1. **Automatic Triggering**: Hooks activate on `Edit`, `MultiEdit`, `Write`, and `Bash` commands
2. **Smart Analysis**: Gemini analyzes your code changes using memory context
3. **Auto-Fixing**: Claude applies fixes based on learned patterns
4. **Background Operation**: Everything happens automatically while you code
5. **Session Summaries**: Get results and insights after each session

### Hook Events
- **PostToolUse**: Triggers collaborative analysis after code modifications
- **Stop**: Generates summary when Claude finishes responding

### Memory-Enhanced Intelligence
- **Gemini** receives context about previous successful fix patterns
- **Claude** gets focused prompts based on file type success rates
- **Both agents** learn from each session to improve over time

### Files Created
```
claude-code-hook.sh      # Main hook integration script
claude-settings.json     # Hook configuration template  
merge-hooks.sh          # Safe merge with existing hooks
setup-hook.sh           # Automated setup
test-hook.sh            # Integration testing
```

## 🧪 **Auto-Testing & Revert Features**

### What happens when Claude applies a fix:
1. **📸 Backup** - Original file backed up automatically
2. **🧪 Pre-test** - Original file tested for baseline
3. **🔧 Apply Fix** - Claude modifies the code
4. **🧪 Post-test** - Modified file tested thoroughly
5. **📊 Compare** - Regression analysis run
6. **✅ Success** - Fix kept if all tests pass
7. **🔄 Auto-revert** - Original restored if tests fail

### Testing Coverage:
- **Python**: Syntax, imports, pylint scores
- **JavaScript/Node.js**: Syntax, ESLint, module loading  
- **TypeScript**: Compilation checks
- **Performance**: Regression detection
- **Logging**: All attempts tracked

## 🧠 **NEW: Session Memory & Learning**

### Complete session tracking:
1. **📝 Session Log** - Every fix attempt with full reasoning
2. **📊 Analytics** - Success rates, patterns, file-level stats
3. **🔍 Insights** - AI-generated learning and recommendations
4. **🎯 Pattern Recognition** - Success/failure pattern analysis
5. **📈 Continuous Learning** - Improving over time

## 📊 Enhanced Monitoring

New monitor commands:
- **`T`** - Run comprehensive tests
- **`R`** - View HTML test report
- **`x`** - View failed fixes (auto-reverted)
- **`m`** - View complete session memory log
- **`i`** - Generate and view session insights
- **Memory status** - Live success rates and learning data

## 📁 Complete File Structure:

```
# Core Hook Integration 🆕
claude-code-hook.sh        # Main hook integration script
claude-settings.json       # Hook configuration template
merge-hooks.sh            # Safe merge with existing hooks
setup-hook.sh             # Automated hook setup
test-hook.sh              # Integration testing

# Agent Scripts
watcher/
├── gemini_loop.sh         # Gemini detection agent
└── claude_loop.sh         # Claude fixing agent

# Data & Results
postbox/
├── failed_fixes.md        # Auto-reverted fixes
├── hook.log              # 🆕 Hook execution log
├── hook_summary.md       # 🆕 Hook session summary
├── test_results/          # Comprehensive test data
│   ├── test_summary.json  # Overall test status
│   ├── test_report.html   # Visual test report
│   └── *.json            # Individual test results
├── memory/                # 🧠 Session memory system
│   ├── session_log.md     # Complete fix history with reasoning
│   ├── analytics.json     # Success rates, patterns, metrics
│   ├── patterns.json      # Success/failure pattern analysis
│   ├── insights.md        # AI-generated session insights
│   ├── memory_summary.json # Live summary for monitoring
│   └── archive/           # Historical session data
└── *.log                 # Enhanced logging

# Utilities
helpers/
├── memory_manager.sh      # 🧠 Session memory management
├── test_runner.sh         # Comprehensive testing
├── monitor.sh             # Enhanced monitoring dashboard
├── setup.sh               # Environment setup
└── cleanup.sh             # System cleanup

# Your Code
codebase/                  # Your project files go here
├── *.py                   # Python files
├── *.js                   # JavaScript files
└── *.ts                   # TypeScript files
```

## 🎯 **Memory Features in Detail**

### Session Log (`postbox/memory/session_log.md`)
```markdown
### Fix #1234567890_123 - success
**Timestamp:** 2024-01-15 14:30:15
**File:** `user_service.py`
**Category:** security
**Duration:** 12s

**Original Issue:**
> Fix security issue in user_service.py at line 15: Remove hard-coded password

**Fix Applied:**
> Replaced hard-coded password with environment variable

**Claude's Reasoning:**
```
The hard-coded password creates a security vulnerability. I replaced it with
os.getenv('ADMIN_PASSWORD', 'default_secure_password') which allows for
secure configuration while maintaining backward compatibility.
```

**Test Results:** ✅ All tests passed
**Status:** 🎉 **SUCCESSFUL** - Fix applied and working
```

### Analytics (`analytics.json`)
- Fix success rates by category
- File-level modification tracking  
- Time-based performance metrics
- Test pass rates and regression analysis

### Insights (`insights.md`)
- AI-generated recommendations
- Pattern analysis and learning
- Success/failure trend analysis
- Continuous improvement suggestions

## 🎮 **Hook Usage Example**

```bash
# 1. Setup (one-time)
./setup-hook.sh
./merge-hooks.sh

# 2. Use Claude Code normally
claude
```

When you edit files, the collaborative agents automatically:
```
🔧 Edit user_service.py
   ↓
🔍 Gemini analyzes changes
   ↓
📋 Creates TODO items
   ↓
🤖 Claude applies fixes
   ↓
🧪 Tests run automatically
   ↓
📊 Summary generated
```

### Real-time Monitoring
```bash
# Watch hook activity
tail -f postbox/hook.log

# View latest results
cat postbox/hook_summary.md
cat postbox/todo.md

# Check session memory
cat postbox/memory/session_log.md
```

### Requirements
- **Claude CLI**: Already installed ✅
- **Gemini CLI**: `npm install -g @google/generative-ai-cli`
- **jq**: For JSON processing (`brew install jq`)
- **API Keys**: Configure Gemini API access
