#!/bin/bash
# Auto-push script for 3D Model Generator to GitHub

set -e

echo "🚀 Auto-Push Script Starting..."

# Configuration
REPO_NAME="3d-model-generator"
GITHUB_USERNAME="shankarelavarasan"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Navigate to project directory
cd "c:\Users\admin\rapid 3d model"

echo "📁 Working directory: $(pwd)"

# Check if Git is initialized
if [ ! -d ".git" ]; then
    echo_warning "Git not initialized, running git init..."
    git init
    git branch -M main
fi

# Add all files to staging
echo "📦 Adding all files to staging..."
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo_warning "No changes to commit, continuing..."
else
    echo "📝 Creating commit..."
    git commit -m "feat: complete 3D model generator with CAD processing pipeline

- ✅ Multi-format CAD file support (STEP, IGES, STL, OBJ)
- ✅ Open-source 3D generation (Hunyuan3D + OpenCascade)
- ✅ Real-time processing with progress tracking
- ✅ Cloud storage integration (Supabase)
- ✅ Responsive Flutter UI with dark/light themes
- ✅ Comprehensive error handling and validation
- ✅ Performance monitoring and caching
- ✅ Complete test suite (unit + integration)
- ✅ Docker deployment ready
- ✅ Production-ready documentation"
    echo_success "Commit created successfully"
fi

# Check if remote exists
if git remote get-url origin >/dev/null 2>&1; then
    echo_warning "Remote origin already exists, updating..."
    git remote set-url origin ${REPO_URL}
else
    echo "🔗 Adding remote repository..."
    git remote add origin ${REPO_URL}
fi

# Force push to handle any conflicts
echo "🚀 Pushing to GitHub..."
git push -u origin main --force-with-lease

echo_success "Auto-push completed successfully!"
echo ""
echo "📊 Repository Information:"
echo "   Repository: ${REPO_URL}"
echo "   Branch: main"
echo "   Status: ✅ Live"
echo ""
echo "🎯 Next Steps:"
echo "   1. Visit: ${REPO_URL}"
echo "   2. Check Actions tab for CI/CD setup"
echo "   3. Enable GitHub Pages in repository settings"
echo "   4. Share your awesome 3D Model Generator!"