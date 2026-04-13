#!/bin/bash
set -e

# Deploy script for Summer Intel Dashboard
# Handles Vercel deployment with proper token management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="summer-intel"

echo "🚀 Deploying Summer Intel Dashboard to Vercel..."

# Get Vercel token from AWS Secrets Manager or environment
if [[ -z "$VERCEL_TOKEN" ]]; then
    echo "🔑 Getting Vercel token from AWS Secrets Manager..."
    if command -v aws >/dev/null 2>&1; then
        VERCEL_TOKEN=$(bash "$HOME/.openclaw/workspace/scripts/aws-secret.sh" "openclaw/vercel-token" | jq -r .token 2>/dev/null || echo "")
    fi
    
    if [[ -z "$VERCEL_TOKEN" ]]; then
        echo "❌ Error: VERCEL_TOKEN not found in environment or AWS Secrets Manager"
        echo "Please set VERCEL_TOKEN environment variable or store in AWS Secrets Manager as openclaw/vercel-token"
        exit 1
    fi
fi

# Change to dashboard directory
cd "$SCRIPT_DIR"

# Check if vercel CLI is installed
if ! command -v vercel >/dev/null 2>&1; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Run build first
echo "🔨 Running build script..."
./build.sh

# Deploy to Vercel
echo "☁️  Deploying to Vercel..."
vercel --prod --yes --token "$VERCEL_TOKEN"

# Get the deployment URL (use the alias)
DEPLOYMENT_URL="https://summer-intel.vercel.app"

echo ""
echo "✅ Deployment complete!"
echo "🌐 Live URL: $DEPLOYMENT_URL"
echo ""
echo "📱 Dashboard is mobile-optimized for checking from Japan!"
echo "🔄 Content auto-refreshes every 5 minutes"
echo "🌙 Dark mode optimized for night viewing"
echo ""

# Test the deployed URL
echo "🔍 Testing deployed site..."
if curl -s -o /dev/null -w "%{http_code}" "$DEPLOYMENT_URL" | grep -q "200"; then
    echo "✅ Site is live and responding!"
    
    # Test if content is properly rendered
    if curl -s "$DEPLOYMENT_URL" | grep -q "Sierra AI"; then
        echo "✅ Content is rendering correctly!"
    else
        echo "⚠️  Site is live but content may not be fully rendered"
    fi
else
    echo "⚠️  Site deployed but may still be propagating..."
fi

echo ""
echo "Next steps for nightly automation:"
echo "1. ✅ Dashboard is live at $DEPLOYMENT_URL"
echo "2. 🔄 Compiler can run: cd $SCRIPT_DIR && ./build.sh && ./deploy.sh"
echo "3. 📱 Optimized for mobile viewing from Japan"
echo "4. 🎯 Auto-refresh keeps content current"
echo ""