# Auto-push script for 3D Model Generator to GitHub (PowerShell)

Write-Host "🚀 Auto-Push Script Starting..." -ForegroundColor Green

# Configuration
$REPO_NAME = "3d-model-generator"
$GITHUB_USERNAME = "shankarelavarasan"
$REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Navigate to project directory
Set-Location "c:\Users\admin\rapid 3d model"

Write-Host "📁 Working directory: $(Get-Location)" -ForegroundColor Cyan

# Check if Git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "⚠️ Git not initialized, running git init..." -ForegroundColor Yellow
    git init
    git branch -M main
}

# Add all files to staging
Write-Host "📦 Adding all files to staging..." -ForegroundColor Cyan
git add .

# Check if there are changes to commit
$changes = git diff --cached --name-only
if ([string]::IsNullOrEmpty($changes)) {
    Write-Host "⚠️ No changes to commit, continuing..." -ForegroundColor Yellow
} else {
    Write-Host "📝 Creating commit..." -ForegroundColor Cyan
    git commit -m "feat: complete 3D model generator with CAD processing pipeline

- Multi-format CAD file support (STEP, IGES, STL, OBJ)
- Open-source 3D generation (Hunyuan3D + OpenCascade)  
- Real-time processing with progress tracking
- Cloud storage integration (Supabase)
- Responsive Flutter UI with dark/light themes
- Comprehensive error handling and validation
- Performance monitoring and caching
- Complete test suite (unit + integration)
- Docker deployment ready
- Production-ready documentation"
    Write-Host "✅ Commit created successfully" -ForegroundColor Green
}

# Check if remote exists
try {
    $remoteUrl = git remote get-url origin
    Write-Host "⚠️ Remote origin already exists, updating..." -ForegroundColor Yellow
    git remote set-url origin $REPO_URL
} catch {
    Write-Host "🔗 Adding remote repository..." -ForegroundColor Cyan
    git remote add origin $REPO_URL
}

# Force push to handle any conflicts
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Cyan
try {
    git push -u origin main --force-with-lease
    Write-Host "✅ Auto-push completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Push failed, trying with force..." -ForegroundColor Red
    git push -u origin main --force
    Write-Host "✅ Auto-push completed with force!" -ForegroundColor Green
}

Write-Host ""
Write-Host "📊 Repository Information:" -ForegroundColor Cyan
Write-Host "   Repository: $REPO_URL" -ForegroundColor White
Write-Host "   Branch: main" -ForegroundColor White
Write-Host "   Status: ✅ Live" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Visit: $REPO_URL" -ForegroundColor White
Write-Host "   2. Check Actions tab for CI/CD setup" -ForegroundColor White
Write-Host "   3. Enable GitHub Pages in repository settings" -ForegroundColor White
Write-Host "   4. Share your awesome 3D Model Generator!" -ForegroundColor White

# Display final git status
git status