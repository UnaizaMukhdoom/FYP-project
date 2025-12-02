# PowerShell script to push all code to GitHub
# Run this from the project root directory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VOGUE AI - Push to GitHub Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project root
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

Write-Host "Current directory: $projectRoot" -ForegroundColor Yellow
Write-Host ""

# Check if git is initialized
if (-not (Test-Path .git)) {
    Write-Host "Git repository not found. Initializing..." -ForegroundColor Yellow
    git init
    Write-Host "✓ Git initialized" -ForegroundColor Green
} else {
    Write-Host "✓ Git repository found" -ForegroundColor Green
}

Write-Host ""

# Check git status
Write-Host "Checking git status..." -ForegroundColor Yellow
git status --short

Write-Host ""
Write-Host "Adding all files..." -ForegroundColor Yellow

# Add all files (respecting .gitignore)
git add .

Write-Host "✓ Files added" -ForegroundColor Green
Write-Host ""

# Check what will be committed
Write-Host "Files to be committed:" -ForegroundColor Cyan
git status --short

Write-Host ""
$commitMessage = Read-Host "Enter commit message (or press Enter for default)"

if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Update Vogue AI Fashion Stylist project - Complete codebase"
}

Write-Host ""
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Changes committed" -ForegroundColor Green
} else {
    Write-Host "⚠ No changes to commit or commit failed" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Do you want to continue and check remote? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") {
        exit
    }
}

Write-Host ""

# Check remote
Write-Host "Checking remote repository..." -ForegroundColor Yellow
$remoteUrl = git remote get-url origin 2>$null

if ($remoteUrl) {
    Write-Host "✓ Remote found: $remoteUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    
    # Get current branch
    $branch = git branch --show-current
    if (-not $branch) {
        $branch = "main"
        git branch -M main 2>$null
    }
    
    Write-Host "Branch: $branch" -ForegroundColor Cyan
    
    # Try to push
    git push -u origin $branch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠ Push failed. Possible reasons:" -ForegroundColor Yellow
        Write-Host "  1. Remote URL not configured" -ForegroundColor Yellow
        Write-Host "  2. Authentication required" -ForegroundColor Yellow
        Write-Host "  3. Branch doesn't exist on remote" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To set up remote, run:" -ForegroundColor Cyan
        Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor White
        Write-Host ""
        Write-Host "Then push with:" -ForegroundColor Cyan
        Write-Host "  git push -u origin $branch" -ForegroundColor White
    }
} else {
    Write-Host "⚠ No remote repository configured" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To add a remote repository, run:" -ForegroundColor Cyan
    Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor White
    Write-Host ""
    $addRemote = Read-Host "Do you want to add a remote now? (Y/N)"
    
    if ($addRemote -eq "Y" -or $addRemote -eq "y") {
        $repoUrl = Read-Host "Enter GitHub repository URL (e.g., https://github.com/username/repo.git)"
        if ($repoUrl) {
            git remote add origin $repoUrl
            Write-Host "✓ Remote added" -ForegroundColor Green
            Write-Host ""
            
            $branch = git branch --show-current
            if (-not $branch) {
                $branch = "main"
                git branch -M main 2>$null
            }
            
            Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
            git push -u origin $branch
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Green
                Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
            }
        }
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan

