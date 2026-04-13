#!/bin/bash
set -e

# Build script for Summer Intel Dashboard
# This script reads markdown files and generates the final HTML
# Safe to run nightly by the compiler cron

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DASHBOARD_DIR="$SCRIPT_DIR"

echo "🔨 Building Summer Intel Dashboard..."
echo "Project dir: $PROJECT_DIR"
echo "Dashboard dir: $DASHBOARD_DIR"

# Check if required files exist
if [[ ! -f "$PROJECT_DIR/MASTER-BRIEF.md" ]]; then
    echo "❌ Error: MASTER-BRIEF.md not found in $PROJECT_DIR"
    exit 1
fi

# Read master brief content and create JavaScript-safe version
echo "📖 Reading MASTER-BRIEF.md..."
# Use node to properly escape content for JavaScript
cat > "$DASHBOARD_DIR/process_content.js" << 'EOF'
const fs = require('fs');
const path = require('path');

// Read master brief
const masterBriefPath = process.argv[2];
const masterBrief = fs.readFileSync(masterBriefPath, 'utf8');

// Escape for JavaScript string literal
function escapeForJs(str) {
    return str
        .replace(/\\/g, '\\\\')
        .replace(/`/g, '\\`')
        .replace(/\$/g, '\\$')
        .replace(/\r?\n/g, '\\n')
        .replace(/'/g, "\\'")
        .replace(/"/g, '\\"');
}

const escapedContent = escapeForJs(masterBrief);
console.log(escapedContent);
EOF

MASTER_BRIEF_ESCAPED=$(node "$DASHBOARD_DIR/process_content.js" "$PROJECT_DIR/MASTER-BRIEF.md")

# Find all daily brief files
echo "📅 Finding daily brief files..."
DAILY_FILES=$(find "$PROJECT_DIR" -name "daily-brief-*.md" -type f | sort -r)
DAILY_BRIEFS_JSON=""

if [[ -n "$DAILY_FILES" ]]; then
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            filename=$(basename "$file")
            # Extract date from filename (daily-brief-2026-03-20.md -> 2026-03-20)
            date_part=$(echo "$filename" | sed 's/daily-brief-\(.*\)\.md/\1/')
            # Format date nicely
            formatted_date=$(date -d "$date_part" '+%b %d, %Y' 2>/dev/null || echo "$date_part")
            
            if [[ -n "$DAILY_BRIEFS_JSON" ]]; then
                DAILY_BRIEFS_JSON+=","
            fi
            
            DAILY_BRIEFS_JSON+="{\"name\":\"Daily Brief\",\"path\":\"../$filename\",\"date\":\"$formatted_date\"}"
        fi
    done <<< "$DAILY_FILES"
else
    echo "⚠️  No daily brief files found"
fi

# Get last updated timestamp
LAST_UPDATED=$(date '+%B %d, %Y at %I:%M %p %Z')

echo "⏱️  Last updated: $LAST_UPDATED"
echo "📊 Found $(echo "$DAILY_FILES" | grep -c . || echo 0) daily brief files"

# Create the final HTML using a template approach
echo "🎨 Generating final HTML..."

# Create template replacement script
cat > "$DASHBOARD_DIR/replace_template.js" << 'EOF'
const fs = require('fs');

const masterBrief = process.argv[2];
const dailyBriefs = process.argv[3];
const lastUpdated = process.argv[4];

const path = require('path');
let template = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');

template = template.replace('`<!-- MASTER_BRIEF_PLACEHOLDER -->`', '`' + masterBrief + '`');
template = template.replace('<!-- DAILY_BRIEFS_PLACEHOLDER -->', dailyBriefs);
template = template.replace('`<!-- LAST_UPDATED_PLACEHOLDER -->`', '`' + lastUpdated + '`');

fs.writeFileSync(path.join(__dirname, 'index.html'), template);
EOF

# Run the replacement
node "$DASHBOARD_DIR/replace_template.js" "$MASTER_BRIEF_ESCAPED" "$DAILY_BRIEFS_JSON" "$LAST_UPDATED"

# Clean up temporary files
rm -f "$DASHBOARD_DIR/process_content.js" "$DASHBOARD_DIR/replace_template.js"

echo "✅ Build complete! Generated index.html with latest content."
echo ""
echo "📂 Files in dashboard directory:"
ls -la "$DASHBOARD_DIR" | grep -E "\.(html|json|sh)$"
echo ""

# Test if the HTML is valid by checking for placeholders
if grep -q "PLACEHOLDER" "$DASHBOARD_DIR/index.html"; then
    echo "⚠️  Warning: Some placeholders may not have been replaced"
else
    echo "✅ All placeholders successfully replaced"
fi

echo ""
echo "🚀 Ready to deploy! Run ./deploy.sh to push to Vercel."