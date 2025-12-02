# Push Code to GitHub - Complete Guide

This guide will help you push your Vogue AI Fashion Stylist project to GitHub.

## Quick Start

### Option 1: Use the Script (Easiest)

**For Windows (PowerShell):**
```powershell
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
.\push_to_github.ps1
```

**For Windows (Command Prompt):**
```cmd
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
push_to_github.bat
```

### Option 2: Manual Commands

## Step-by-Step Instructions

### 1. Initialize Git (if not already done)

```bash
cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\Vogue-AI-Next-_-Gen-Fashion-Stylist-main"
git init
```

### 2. Add All Files

```bash
git add .
```

This will add all files except those in `.gitignore`:
- ✅ Source code
- ✅ Configuration files
- ✅ Documentation
- ❌ Build files (excluded by .gitignore)
- ❌ node_modules (excluded)
- ❌ __pycache__ (excluded)

### 3. Commit Changes

```bash
git commit -m "Update Vogue AI Fashion Stylist - Complete codebase with admin panel"
```

### 4. Set Up GitHub Repository

#### A. Create Repository on GitHub

1. Go to [GitHub](https://github.com)
2. Click the **+** icon → **New repository**
3. Enter repository name (e.g., `vogue-ai-fashion-stylist`)
4. Choose public or private
5. **DO NOT** initialize with README, .gitignore, or license (you already have these)
6. Click **Create repository**

#### B. Add Remote to Your Local Repository

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

Replace:
- `YOUR_USERNAME` with your GitHub username
- `YOUR_REPO_NAME` with your repository name

**Example:**
```bash
git remote add origin https://github.com/johndoe/vogue-ai-fashion-stylist.git
```

#### C. Rename Branch to main (if needed)

```bash
git branch -M main
```

### 5. Push to GitHub

```bash
git push -u origin main
```

If prompted for authentication:
- **Personal Access Token**: Use a GitHub Personal Access Token (not password)
- Create one at: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

## Troubleshooting

### Problem: "fatal: remote origin already exists"

**Solution:** Remove and re-add remote
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

### Problem: Authentication Failed

**Solution:** Use Personal Access Token
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scopes: `repo` (full control)
4. Copy the token
5. Use token as password when pushing

### Problem: Large Files Error

**Solution:** If you have large files (>100MB), they need Git LFS
```bash
git lfs install
git lfs track "*.pkl"
git lfs track "*.tflite"
git add .gitattributes
git commit -m "Add Git LFS tracking for large files"
```

### Problem: "Updates were rejected"

**Solution:** Pull first, then push
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

## What Gets Pushed?

✅ **Will be pushed:**
- Flutter app code (`lib/`, `pubspec.yaml`)
- Python backend (`api/`)
- Admin panel (`admin-panel/`)
- Configuration files
- Documentation (README.md, etc.)
- Firebase config
- Chatbot models (if < 50MB)

❌ **Will NOT be pushed** (excluded by .gitignore):
- Build artifacts (`build/`, `android/build/`)
- `node_modules/`
- `__pycache__/`
- `.dart_tool/`
- Large generated files

## After Pushing

1. ✅ Verify on GitHub: Check your repository page
2. ✅ Check file sizes: Ensure all files uploaded correctly
3. ✅ Update README: Add setup instructions if needed
4. ✅ Set up CI/CD: Configure GitHub Actions if needed

## Future Updates

For future updates, simply run:

```bash
git add .
git commit -m "Your commit message"
git push
```

Or use the provided scripts:
- `push_to_github.ps1` (PowerShell)
- `push_to_github.bat` (Command Prompt)

## Need Help?

If you encounter any issues:
1. Check git status: `git status`
2. Check remote: `git remote -v`
3. Check branches: `git branch -a`
4. Review error messages carefully

---

**Note:** Make sure you're authenticated with GitHub. If using HTTPS, you'll need a Personal Access Token. If using SSH, ensure your SSH keys are set up.

