#!/bin/bash

# Claude Code Docker - Blockchain Development Setup
echo "🚀 Setting up Blockchain Development Environment"
echo "=============================================="

# This script runs INSIDE the Claude Code container to install blockchain tools

# 1. Install Smithery CLI for MCP server management
echo "📦 Installing Smithery CLI..."
npm install -g @smithery/cli

# 2. Install ZetaChain CLI
echo "⛓️  Installing ZetaChain CLI..."
npm install -g zetachain

# 3. Install Solana CLI tools
echo "☀️  Installing Solana tools..."
npm install -g @solana/cli

# 4. Install common blockchain libraries
echo "🔧 Installing blockchain libraries..."
npm install -g @web3.js/web3.js
npm install -g ethers
npm install -g @sui/cli

# 5. Configure MCP servers for Claude Code
echo "🤖 Adding blockchain MCP servers..."

# Add Universal Blockchain MCP
export SMITHERY_API_KEY="9f97477d-6fc9-4431-b5c9-e01581d1a451"

# Install from Smithery
smithery install @ExpertVagabond/universal-blockchain-mcp --client claude-code
smithery install @ExpertVagabond/solana-mcp-server --client claude-code
smithery install @ExpertVagabond/sui-mcp-server --client claude-code

# 6. Create workspace directories
echo "📁 Setting up workspace..."
mkdir -p /workspace/blockchain-projects
mkdir -p /workspace/smart-contracts
mkdir -p /workspace/defi-apps
mkdir -p /workspace/cross-chain

# 7. Create example configuration
cat > /workspace/mcp-blockchain-config.json << 'EOF'
{
  "mcpServers": {
    "universal-blockchain": {
      "command": "npx",
      "args": ["@ExpertVagabond/universal-blockchain-mcp"],
      "env": {
        "NODE_ENV": "development"
      }
    },
    "solana-tools": {
      "command": "npx",
      "args": ["@ExpertVagabond/solana-mcp-server"],
      "env": {
        "SOLANA_NETWORK": "devnet"
      }
    },
    "sui-tools": {
      "command": "npx",
      "args": ["@ExpertVagabond/sui-mcp-server"],
      "env": {
        "SUI_NETWORK": "testnet"
      }
    }
  }
}
EOF

echo ""
echo "✨ Blockchain development environment ready!"
echo ""
echo "🔧 Available tools:"
echo "   • ZetaChain CLI: zetachain --help"
echo "   • Solana CLI: solana --help"
echo "   • Universal Blockchain MCP server"
echo "   • Sui CLI: sui --help"
echo "   • Web3.js and Ethers libraries"
echo ""
echo "🚀 Usage examples:"
echo "   claude --mcp-config /workspace/mcp-blockchain-config.json 'Create a cross-chain DeFi app'"
echo "   claude 'Build a Solana NFT marketplace with TypeScript'"
echo "   claude 'Deploy a smart contract on ZetaChain testnet'"
echo ""
echo "📚 Claude Code now has blockchain superpowers!"