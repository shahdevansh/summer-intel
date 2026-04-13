# 🎯 Summer Intel Dashboard

A beautiful, responsive dashboard that displays Devansh's summer role research in real-time.

## 🌐 Live Site
**https://summer-intel.vercel.app**

## 🏗️ Architecture
- **Static site** with embedded CSS and JavaScript
- **Markdown rendering** via marked.js from CDN
- **Dark theme** optimized for mobile viewing (Japan-friendly)
- **Auto-refresh** every 5 minutes to display latest content
- **Responsive design** works perfectly on phones

## 📂 Files
- `index.html` - Main dashboard template 
- `build.sh` - Generates final HTML with latest markdown content
- `deploy.sh` - Deploys to Vercel with proper token management
- `vercel.json` - Deployment configuration
- `package.json` - Project metadata

## 🔄 Automation
Perfect for nightly automation by the compiler:

```bash
cd projects/summer-roles/dashboard
./build.sh && ./deploy.sh
```

This will:
1. Read `../MASTER-BRIEF.md` and all `../daily-brief-*.md` files
2. Inject content into the HTML template
3. Deploy updated site to Vercel
4. Site auto-refreshes every 5 minutes for users

## 🎨 Design Features
- **Linear/Notion-inspired** dark theme (#0a0a0a background)
- **Gradient title** with emoji icons
- **Priority indicators** (🔴 🟡 ⚪) for roles
- **Mobile-first responsive** design
- **Typography** optimized for readability
- **Auto-refresh indicator** when content updates

## 🚀 Quick Setup
1. Content is automatically pulled from parent directory markdown files
2. Build script is idempotent (safe to run repeatedly)
3. Deploy script handles Vercel token via AWS Secrets Manager
4. No dependencies needed - everything runs from the scripts

Perfect for Devansh to check his summer role intel from his phone while in Japan! 🇯🇵