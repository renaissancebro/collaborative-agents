# Collaborative Agents System

A dual-agent workflow system with Gemini for detection and Claude for fixes.

## Setup
```bash
cd helpers
./setup.sh
```

## Run
```bash
# Terminal 1
cd watcher && ./gemini_loop.sh

# Terminal 2  
cd watcher && ./claude_loop.sh

# Terminal 3
cd helpers && ./monitor.sh
```
