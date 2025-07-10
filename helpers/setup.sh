#!/bin/bash

# Setup script for Dual-Agent Code Review System

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running from correct directory
check_directory() {
    if [ ! -f "../README.md" ] || [ ! -d "../watcher" ]; then
        error "Please run this script from the helpers/ directory"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    info "Checking system requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js is required but not installed"
        echo "Install from: https://nodejs.org/"
        exit 1
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        error "Python 3 is required but not installed"
        exit 1
    fi
    
    # Check jq for JSON parsing
    if ! command -v jq &> /dev/null; then
        warn "jq is recommended for JSON parsing"
        echo "Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)"
    fi
    
    success "System requirements check passed"
}

# Check CLI tools
check_cli_tools() {
    info "Checking CLI tools..."
    
    # Check Gemini CLI
    if ! command -v gemini &> /dev/null; then
        warn "Gemini CLI not found"
        echo "Install with: npm install -g @google/generative-ai-cli"
        echo "Then configure: gemini config set-api-key YOUR_API_KEY"
    else
        success "Gemini CLI found"
    fi
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        warn "Claude CLI not found"
        echo "Install from: https://docs.anthropic.com/claude/docs/claude-code"
    else
        success "Claude CLI found"
    fi
}

# Set up directories and permissions
setup_directories() {
    info "Setting up directories and permissions..."
    
    # Make scripts executable
    chmod +x ../watcher/*.sh
    chmod +x *.sh
    
    # Create log directory if needed
    mkdir -p ../postbox
    
    # Initialize log files
    touch ../postbox/gemini.log
    touch ../postbox/claude.log
    
    success "Directories and permissions configured"
}

# Install optional dependencies
install_dependencies() {
    info "Installing optional dependencies..."
    
    # Install Python linting tools
    if command -v pip3 &> /dev/null; then
        pip3 install --user pylint pycodestyle 2>/dev/null || warn "Failed to install Python linting tools"
    fi
    
    # Install TypeScript for syntax checking
    if command -v npm &> /dev/null; then
        npm install -g typescript 2>/dev/null || warn "Failed to install TypeScript"
    fi
    
    success "Optional dependencies installed"
}

# Create environment file template
create_env_template() {
    info "Creating environment template..."
    
    cat > ../.env.template << 'EOF'
# Dual-Agent System Environment Variables

# Gemini Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Claude Configuration (usually handled by Claude CLI)
# ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: Custom scan intervals (in seconds)
GEMINI_SCAN_INTERVAL=300
CLAUDE_SCAN_INTERVAL=60

# Optional: Debug mode
DEBUG=false

# Optional: Custom paths
# CODEBASE_DIR=../codebase
# POSTBOX_DIR=../postbox
EOF
    
    success "Environment template created at .env.template"
}

# Test basic functionality
test_setup() {
    info "Testing basic functionality..."
    
    # Test directory structure
    for dir in "../watcher" "../postbox" "../codebase"; do
        if [ ! -d "$dir" ]; then
            error "Directory missing: $dir"
            exit 1
        fi
    done
    
    # Test file permissions
    for script in "../watcher/gemini_loop.sh" "../watcher/claude_loop.sh"; do
        if [ ! -x "$script" ]; then
            error "Script not executable: $script"
            exit 1
        fi
    done
    
    # Test sample files exist
    if [ ! -f "../codebase/user_service.py" ]; then
        error "Sample codebase files missing"
        exit 1
    fi
    
    success "Basic functionality test passed"
}

# Main setup function
main() {
    echo "🚀 Setting up Dual-Agent Code Review System"
    echo "=========================================="
    
    check_directory
    check_requirements
    check_cli_tools
    setup_directories
    install_dependencies
    create_env_template
    test_setup
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure API keys:"
    echo "   - Gemini: gemini config set-api-key YOUR_KEY"
    echo "   - Claude: Should be configured via Claude CLI"
    echo ""
    echo "2. Start the agents:"
    echo "   Terminal 1: cd watcher && ./gemini_loop.sh"
    echo "   Terminal 2: cd watcher && ./claude_loop.sh"
    echo ""
    echo "3. Monitor progress:"
    echo "   ./monitor.sh"
    echo ""
    echo "For detailed instructions, see README.md"
}

# Run main function
main "$@"