# Collaborative Agents System

A dual-agent workflow system with **comprehensive self-testing and auto-revert** capabilities:
- **Gemini Agent** detects code issues and creates TODOs
- **Claude Agent** applies fixes with automatic testing and rollback
- **Smart Testing** runs before/after comparisons and reverts failed fixes
- **Comprehensive Monitoring** tracks everything in real-time

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

## 📊 Enhanced Monitoring

New monitor commands:
- **`T`** - Run comprehensive tests
- **`R`** - View HTML test report
- **`x`** - View failed fixes (auto-reverted)
- **Test status** - Live test results in dashboard

## 📁 New Files Created:

```
postbox/
├── failed_fixes.md        # Auto-reverted fixes
├── test_results/          # Comprehensive test data
│   ├── test_summary.json  # Overall test status
│   ├── test_report.html   # Visual test report
│   └── *.json            # Individual test results
└── *.log                 # Enhanced logging
```
