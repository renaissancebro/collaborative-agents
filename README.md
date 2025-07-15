# Collaborative Agents System

## 🚀 **Use Claude Code Normally - Agents Work Automatically!**

A dual-agent workflow system with **comprehensive self-testing, auto-revert, and session memory** capabilities:
- **Gemini Agent** detects code issues and creates TODOs
- **Claude Agent** applies fixes with automatic testing and rollback  
- **Smart Testing** runs before/after comparisons and reverts failed fixes
- **Session Memory** tracks all fixes, reasoning, and breakage patterns
- **Comprehensive Monitoring** with analytics and insights
- **🆕 Claude Code Hook Integration** - Works seamlessly as a Claude Code hook

### ✨ **Key Feature**: After setup, just use Claude Code normally - no new commands to learn!

## 🚀 Quick Start

### Option 1: Claude Code Hook Integration (Recommended) ⭐
```bash
# One-time setup (takes 30 seconds)
./setup-hook.sh
./merge-hooks.sh

# Test the integration (optional)
./test-hook.sh

# That's it! Now use Claude Code normally - collaborative agents work automatically!
claude
```

**✨ After setup, collaborative agents run automatically in the background every time you:**
- Edit files with Claude Code
- Write new files  
- Run bash commands
- **No manual intervention needed!**

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

## 🎯 **Claude Code Hook Integration - Works Automatically!**

### 🔄 How It Works Behind the Scenes
When you use Claude Code normally, the collaborative agents automatically:

```
You edit a file with Claude Code
          ↓
🎯 Hook triggers instantly
          ↓
🔍 Gemini analyzes your changes (with memory context)
          ↓
📋 Creates TODO items for issues found
          ↓
🤖 Claude applies fixes automatically
          ↓
🧪 Tests run to verify fixes work
          ↓
📊 Results logged to memory system
          ↓
✅ Summary generated for you
```

### 🎮 Zero-Effort Usage
```bash
# After one-time setup, just use Claude Code normally:
claude

# Edit any file - collaborative agents work automatically!
# No commands to remember, no manual steps
```

### 🧠 Intelligence Features
- **Memory-Enhanced**: Gemini gets context about previous successful fixes
- **Success-Driven**: Claude focuses on fix patterns that work
- **Self-Learning**: Both agents improve over time from session data
- **Auto-Revert**: Failed fixes are automatically rolled back

### 📁 Hook Files Created
```
claude-code-hook.sh      # Main hook integration script
claude-settings.json     # Hook configuration template  
merge-hooks.sh          # Safe merge with existing hooks
setup-hook.sh           # Automated setup
test-hook.sh            # Integration testing
```

### 🚨 **Important**: macOS Compatibility Fixed
- ✅ Fixed `realpath` issues for macOS
- ✅ Enhanced file finding logic  
- ✅ Added proper error handling
- ✅ Cross-platform compatibility

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

## 🎮 **Real-World Usage Example**

### 1. One-Time Setup (30 seconds)
```bash
./setup-hook.sh
./merge-hooks.sh
```

### 2. Normal Claude Code Usage
```bash
claude
```

### 3. Automatic Background Operation
```bash
# You edit a file like this:
> Edit user_service.py and add error handling

# Behind the scenes (automatically):
🎯 Hook triggers
🔍 Gemini: "Found security issue in user_service.py:42"
📋 Creates TODO: "Fix hard-coded password"
🤖 Claude: Applies fix with environment variable
🧪 Tests pass ✅
📊 Logs to memory system
✅ Summary: "1 security issue fixed successfully"
```

### 4. Monitor Results (Optional)
```bash
# Watch real-time activity
tail -f postbox/hook.log

# View session results
cat postbox/hook_summary.md
cat postbox/todo.md
cat postbox/memory/session_log.md
```

## 🔧 **Setup Requirements**
- **Claude CLI**: Already installed ✅
- **Gemini CLI**: `npm install -g @google/generative-ai-cli`
- **jq**: For JSON processing (`brew install jq`)
- **API Keys**: Configure Gemini API access

## 🎯 **Key Benefits**
- **Zero Learning Curve**: Use Claude Code exactly as before
- **Automatic Quality**: Code issues fixed in background
- **Memory System**: Learns from each session
- **Safe Operation**: Auto-reverts failed fixes
- **No Interruption**: Works seamlessly while you code
