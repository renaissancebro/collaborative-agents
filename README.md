# Collaborative Agents System

A dual-agent workflow system with **comprehensive self-testing, auto-revert, and session memory** capabilities:
- **Gemini Agent** detects code issues and creates TODOs
- **Claude Agent** applies fixes with automatic testing and rollback
- **Smart Testing** runs before/after comparisons and reverts failed fixes
- **Session Memory** tracks all fixes, reasoning, and breakage patterns
- **Comprehensive Monitoring** with analytics and insights
- **🆕 Claude Code Hook Integration** - Works seamlessly as a Claude Code hook

## 🚀 Quick Start

### Setup
```bash
cd helpers
./setup.sh
```

### Run the System
```bash
# Terminal 1 - Gemini Agent
cd watcher && ./gemini_loop.sh

# Terminal 2 - Claude Agent  
cd watcher && ./claude_loop.sh

# Terminal 3 - Monitor Dashboard
cd helpers && ./monitor.sh
```

## 🧪 **NEW: Auto-Testing & Revert Features**

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
postbox/
├── failed_fixes.md        # Auto-reverted fixes
├── test_results/          # Comprehensive test data
│   ├── test_summary.json  # Overall test status
│   ├── test_report.html   # Visual test report
│   └── *.json            # Individual test results
├── memory/                # 🧠 NEW: Session memory system
│   ├── session_log.md     # Complete fix history with reasoning
│   ├── analytics.json     # Success rates, patterns, metrics
│   ├── patterns.json      # Success/failure pattern analysis
│   ├── insights.md        # AI-generated session insights
│   ├── memory_summary.json # Live summary for monitoring
│   └── archive/           # Historical session data
└── *.log                 # Enhanced logging

helpers/
├── memory_manager.sh      # 🧠 NEW: Session memory management
├── test_runner.sh         # Comprehensive testing
├── monitor.sh             # Enhanced monitoring dashboard
├── setup.sh               # Environment setup
└── cleanup.sh             # System cleanup
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
