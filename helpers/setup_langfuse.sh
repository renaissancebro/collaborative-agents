#!/bin/bash

# Langfuse Setup Helper for Collaborative Agents

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[SETUP]${NC} $1"
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

echo "🔗 Langfuse Integration Setup for Collaborative Agents"
echo "=================================================="
echo ""

# Check if already configured
if [ -n "${LANGFUSE_PUBLIC_KEY:-}" ] && [ -n "${LANGFUSE_SECRET_KEY:-}" ]; then
    success "Langfuse keys already configured!"
    echo "Public key: ${LANGFUSE_PUBLIC_KEY:0:10}..."
    echo "Secret key: ${LANGFUSE_SECRET_KEY:0:10}..."
    echo ""
    echo "Want to test the integration? Run:"
    echo "  ./langfuse_integration.sh sync"
    exit 0
fi

echo "This script will help you integrate Langfuse with your Collaborative Agents system."
echo ""
echo "📋 What you need:"
echo "1. A Langfuse account (free at https://langfuse.com)"
echo "2. Your Langfuse API keys (public and secret)"
echo ""

read -p "Do you have a Langfuse account and API keys? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    info "Getting started with Langfuse:"
    echo "1. Go to https://langfuse.com"
    echo "2. Sign up for a free account"
    echo "3. Create a new project"
    echo "4. Go to Settings → API Keys"
    echo "5. Copy your public and secret keys"
    echo "6. Run this script again"
    echo ""
    echo "Langfuse will give you:"
    echo "✅ Advanced analytics and insights"
    echo "✅ Team collaboration features"
    echo "✅ Session tracking and monitoring"
    echo "✅ Custom dashboards and alerts"
    exit 0
fi

echo ""
info "Please enter your Langfuse API keys:"
echo ""

# Get public key
read -p "Langfuse Public Key (pk_...): " public_key
if [[ ! $public_key =~ ^pk_ ]]; then
    error "Public key should start with 'pk_'"
    exit 1
fi

# Get secret key  
read -s -p "Langfuse Secret Key (sk_...): " secret_key
echo ""
if [[ ! $secret_key =~ ^sk_ ]]; then
    error "Secret key should start with 'sk_'"
    exit 1
fi

echo ""
info "Adding keys to your shell configuration..."

# Add to .zshrc
if [ -f "$HOME/.zshrc" ]; then
    # Check if already exists
    if grep -q "LANGFUSE_PUBLIC_KEY" "$HOME/.zshrc"; then
        warn "Langfuse keys already in .zshrc, updating..."
        # Remove old entries
        sed -i.bak '/LANGFUSE_PUBLIC_KEY/d' "$HOME/.zshrc"
        sed -i.bak '/LANGFUSE_SECRET_KEY/d' "$HOME/.zshrc"
    fi
    
    # Add new entries
    echo "" >> "$HOME/.zshrc"
    echo "# Langfuse Integration for Collaborative Agents" >> "$HOME/.zshrc"
    echo "export LANGFUSE_PUBLIC_KEY=\"$public_key\"" >> "$HOME/.zshrc"
    echo "export LANGFUSE_SECRET_KEY=\"$secret_key\"" >> "$HOME/.zshrc"
    
    success "Keys added to ~/.zshrc"
else
    warn "~/.zshrc not found, creating environment file instead"
    echo "export LANGFUSE_PUBLIC_KEY=\"$public_key\"" > ../.env
    echo "export LANGFUSE_SECRET_KEY=\"$secret_key\"" >> ../.env
    success "Keys saved to .env file"
fi

# Test the configuration
info "Testing Langfuse connection..."

export LANGFUSE_PUBLIC_KEY="$public_key"
export LANGFUSE_SECRET_KEY="$secret_key"

# Simple test
if curl -s -f --max-time 10 \
    -H "Authorization: Basic $(echo -n "${public_key}:${secret_key}" | base64)" \
    "https://cloud.langfuse.com/api/public/health" > /dev/null; then
    success "✅ Langfuse connection successful!"
else
    error "❌ Could not connect to Langfuse. Please check your keys."
    exit 1
fi

echo ""
echo "🎉 Langfuse integration setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Reload your shell: source ~/.zshrc"
echo "2. Test the integration: ./langfuse_integration.sh sync"
echo "3. Start continuous monitoring: ./langfuse_integration.sh monitor"
echo ""
echo "🔗 What gets sent to Langfuse:"
echo "✅ Every fix attempt with Claude's reasoning"
echo "✅ Session analytics and success rates"
echo "✅ AI-generated insights and learning"
echo "✅ Pattern analysis and performance metrics"
echo ""
echo "📊 View your data at: https://cloud.langfuse.com"