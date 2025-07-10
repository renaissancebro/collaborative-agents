# 🚀 Collaborative Agents Usage Guide

## Quick Start (5 minutes)

### 1. **Setup Your Environment**
```bash
cd /Users/joshuafreeman/collaborative-agents

# First-time setup
cd helpers && ./setup.sh

# The setup will tell you what's missing and how to install it
```

### 2. **Configure API Keys**
```bash
# For Gemini (required)
gemini config set-api-key YOUR_GEMINI_API_KEY

# Claude CLI should already be configured since you're using Claude Code

# For Langfuse (optional but recommended)
export LANGFUSE_PUBLIC_KEY="your_public_key"
export LANGFUSE_SECRET_KEY="your_secret_key"
```

### 3. **Start the System**
```bash
# Terminal 1 - Gemini Agent
cd watcher && ./gemini_loop.sh

# Terminal 2 - Claude Agent  
cd watcher && ./claude_loop.sh

# Terminal 3 - Monitor Dashboard
cd helpers && ./monitor.sh
```

### 4. **Watch It Work!**
- **Gemini** will scan `codebase/` every 5 minutes for issues
- **Claude** will read TODOs and apply fixes with testing
- **Monitor** shows everything happening in real-time

---

## 📊 Using the Monitor Dashboard

### **Live Dashboard Commands:**
- **`r`** - Refresh display
- **`g`** - View Gemini logs  
- **`c`** - View Claude logs
- **`t`** - View current TODOs
- **`f`** - View completed fixes
- **`x`** - View failed/reverted fixes
- **`m`** - 🧠 View session memory log
- **`i`** - 🧠 Generate AI insights
- **`T`** - Run comprehensive tests
- **`R`** - View HTML test report
- **`s`** - Start agents
- **`k`** - Kill agents
- **`q`** - Quit monitor

### **What You'll See:**
```
🤖 Agent Status
✅ Gemini Agent (PID: 12345) - Running
✅ Claude Agent (PID: 67890) - Running

📋 TODO Status  
Pending TODOs: 3
📝 Recent TODO items:
   • Fix security issue in user_service.py at line 15
   • Fix performance issue in data_processor.js at line 42
   • Fix code smell in config_manager.py at line 28

✅ Completed Status
Completed fixes: 5
Failed fixes (auto-reverted): 1

🧪 Test Status
Total files tested: 8
Tests passed: 7  
Tests failed: 1

🧠 Session Memory
Fix attempts: 6
Success rate: 83%
Files touched: 3
Latest: success
```

---

## 🧠 Using Session Memory & Analytics

### **View Complete Session History:**
```bash
# In monitor, press 'm' or:
cat postbox/memory/session_log.md
```

**Example entry:**
```markdown
### Fix #1641234567_89 - success
**Timestamp:** 2024-01-15 14:30:15
**File:** `user_service.py`
**Category:** security
**Duration:** 12s

**Original Issue:**
> Fix security issue in user_service.py at line 15: Remove hard-coded password

**Fix Applied:**
> Replaced hard-coded password with environment variable

**Claude's Reasoning:**
The hard-coded password creates a security vulnerability. I replaced it with
os.getenv('ADMIN_PASSWORD', 'default_secure_password') which allows for
secure configuration while maintaining backward compatibility.

**Test Results:** ✅ All tests passed  
**Status:** 🎉 **SUCCESSFUL** - Fix applied and working
```

### **Generate AI Insights:**
```bash
# In monitor, press 'i' or:
./helpers/memory_manager.sh insights

# View insights
cat postbox/memory/insights.md
```

### **Manual Memory Commands:**
```bash
# View session statistics
./helpers/memory_manager.sh stats

# View success/failure patterns
./helpers/memory_manager.sh patterns

# Archive current session
./helpers/memory_manager.sh archive
```

---

## 🔗 Langfuse Integration

### **Setup Langfuse:**
```bash
# Add to ~/.zshrc
export LANGFUSE_PUBLIC_KEY="pk_..."
export LANGFUSE_SECRET_KEY="sk_..."

# Reload shell
source ~/.zshrc
```

### **Use Langfuse Integration:**

**Option 1: One-time sync**
```bash
# Sync current session to Langfuse
./helpers/langfuse_integration.sh sync
```

**Option 2: Continuous monitoring**
```bash
# Terminal 4 - Langfuse sync (run alongside other terminals)
cd helpers && ./langfuse_integration.sh monitor
```

**What gets sent to Langfuse:**
- ✅ Every fix attempt with reasoning
- ✅ Session analytics and success rates  
- ✅ AI-generated insights
- ✅ Pattern analysis and learning data
- ✅ Performance metrics and timing

### **View in Langfuse Dashboard:**
- **Traces**: Each session with complete analytics
- **Events**: Individual fix attempts with reasoning
- **Metrics**: Success rates, categories, performance
- **Insights**: AI-generated learning recommendations

---

## 🧪 Testing & Quality Assurance

### **Automatic Testing:**
- Every fix is tested before and after
- Regression analysis prevents breaking changes
- Failed fixes are automatically reverted
- Complete test history tracked

### **Manual Testing:**
```bash
# Test all files
./helpers/test_runner.sh test-all

# Test specific file
./helpers/test_runner.sh test-file codebase/user_service.py

# View test report
open postbox/test_results/test_report.html
```

### **Test Coverage:**
- **Python**: Syntax, imports, pylint scores
- **JavaScript**: Syntax, ESLint, module loading
- **TypeScript**: Compilation checks
- **Performance**: Regression detection

---

## 🎯 Common Workflows

### **Development Workflow:**
1. **Add your code** to `codebase/` directory
2. **Start the system** (3 terminals)
3. **Watch Gemini** detect issues → writes TODOs
4. **Watch Claude** apply fixes → with testing
5. **Review results** in monitor dashboard
6. **Check memory** for learning insights

### **Code Review Workflow:**
1. **Add problematic code** to `codebase/`
2. **Let system process** automatically
3. **Review session log** for all changes made
4. **Check insights** for patterns and recommendations
5. **Export to Langfuse** for team review

### **Learning Workflow:**
1. **Run system on various codebases**
2. **Accumulate session data** over time
3. **Generate insights** regularly
4. **Analyze patterns** in Langfuse
5. **Improve prompts** based on success patterns

---

## 🔧 Customization

### **Adjust Scan Intervals:**
```bash
# Edit gemini_loop.sh
SCAN_INTERVAL=300  # 5 minutes (default)

# Edit claude_loop.sh  
SCAN_INTERVAL=60   # 1 minute (default)
```

### **Customize Issue Detection:**
Edit the Gemini prompt in `watcher/gemini_loop.sh` to focus on specific issues:
- Security vulnerabilities
- Performance problems
- Code style issues
- Architecture problems

### **Add Your Own Code:**
```bash
# Replace sample files with your code
rm codebase/*.py codebase/*.js
cp /path/to/your/code/* codebase/

# Or add to existing files
cp /path/to/your/files/* codebase/
```

---

## 🛟 Troubleshooting

### **Common Issues:**

**"Gemini CLI not found"**
```bash
npm install -g @google/generative-ai-cli
gemini config set-api-key YOUR_KEY
```

**"Claude CLI not found"**
```bash
# Claude CLI should be available since you're using Claude Code
claude --version
```

**"No issues detected"**
- Check if your code actually has issues
- Review Gemini logs: `tail -f postbox/gemini.log`
- Try adding intentionally problematic code

**"Fixes not applying"**  
- Check Claude logs: `tail -f postbox/claude.log`
- Verify file permissions
- Check if tests are passing

### **Debug Mode:**
```bash
# Enable debug logging
export DEBUG=1

# Check detailed logs
tail -f postbox/*.log
```

### **Reset Everything:**
```bash
# Clean up and start fresh
./helpers/cleanup.sh --force
```

---

## 📈 Advanced Usage

### **Custom Langfuse Workflows:**

**Send specific events:**
```bash
# Send just analytics
./helpers/langfuse_integration.sh analytics

# Send just insights
./helpers/langfuse_integration.sh insights
```

**Custom Langfuse analysis:**
- Use Langfuse's playground to analyze patterns
- Create custom dashboards for team metrics
- Set up alerts for low success rates
- Track improvement over time

### **Integration with CI/CD:**
```bash
# Add to your CI pipeline
./helpers/test_runner.sh test-all
./helpers/langfuse_integration.sh sync
```

### **Team Collaboration:**
- Share session logs for code review
- Use Langfuse for team analytics
- Archive sessions for historical analysis
- Export insights for documentation

---

## 🎉 You're Ready!

The system provides:
- ✅ **Automated code improvement** with Gemini + Claude
- ✅ **Complete safety** with testing and auto-revert
- ✅ **Full memory** of every change with reasoning
- ✅ **Advanced analytics** and learning insights
- ✅ **Langfuse integration** for team collaboration

**Start with the basic workflow and explore the advanced features as you go!**