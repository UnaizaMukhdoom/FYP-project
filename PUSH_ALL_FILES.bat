@echo off
REM Script to push ALL files including admin panel and wardrobe files to GitHub
REM Repository: https://github.com/UnaizaMukhdoom/Vogue-AI-Next-_-Gen-Fashion-Stylist

echo ========================================
echo Pushing All Files to GitHub
echo Including: Admin Panel + Wardrobe Files
echo ========================================
echo.

cd /d "%~dp0"

echo Current directory: %CD%
echo.

REM Check if git is initialized
if not exist ".git" (
    echo Git repository not found. Initializing...
    git init
    echo.
)

REM Set up remote
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo Setting up remote repository...
    git remote add origin https://github.com/UnaizaMukhdoom/Vogue-AI-Next-_-Gen-Fashion-Stylist.git
    echo Remote added.
    echo.
) else (
    echo Checking remote...
    git remote set-url origin https://github.com/UnaizaMukhdoom/Vogue-AI-Next-_-Gen-Fashion-Stylist.git
    echo Remote configured.
    echo.
)

echo ========================================
echo Files to be pushed:
echo ========================================
echo.
echo Admin Panel Files:
echo   - admin-panel/ (all files)
echo.
echo Wardrobe Files:
echo   - lib/screens/wardrobe_screen.dart
echo   - lib/screens/add_wardrobe_item_screen.dart
echo   - lib/screens/outfit_planner_screen.dart
echo   - lib/services/wardrobe_service.dart
echo   - lib/models/wardrobe_item.dart
echo   - api/data/wardrobe.json
echo   - RUN_VIRTUAL_WARDROBE.md
echo   - START_WARDROBE_BACKEND.bat
echo.
echo Plus all other modified files...
echo.

pause

echo.
echo Adding ALL files (including admin-panel and wardrobe)...
git add -A
echo.

echo Files staged:
git status --short
echo.

set /p commitMessage="Enter commit message (or press Enter for default): "

if "%commitMessage%"=="" (
    set commitMessage=Add admin panel and wardrobe features - Complete update
)

echo.
echo Committing changes...
git commit -m "%commitMessage%"

if %errorlevel% neq 0 (
    echo.
    echo ⚠ No changes to commit or commit failed
    echo Trying to pull first...
    git pull origin main --rebase 2>nul
    if %errorlevel% equ 0 (
        echo Pull successful. Retrying commit...
        git commit -m "%commitMessage%"
    )
)

echo.
echo Pushing to GitHub...
for /f "tokens=*" %%i in ('git branch --show-current') do set branch=%%i
if "%branch%"=="" (
    set branch=main
    git branch -M main 2>nul
)

echo Branch: %branch%
git push origin %branch%

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo ✓ SUCCESS! All files pushed to GitHub!
    echo ========================================
    echo.
    echo Repository: https://github.com/UnaizaMukhdoom/Vogue-AI-Next-_-Gen-Fashion-Stylist
    echo.
    echo Files pushed:
    echo   ✓ Admin Panel (admin-panel/)
    echo   ✓ Wardrobe Files (lib/screens/wardrobe_*.dart, lib/services/wardrobe_service.dart)
    echo   ✓ All other modified files
    echo   ✓ Deleted files removed from GitHub
) else (
    echo.
    echo ⚠ Push failed. Trying to set upstream...
    git push -u origin %branch%
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo ✓ SUCCESS! All files pushed to GitHub!
        echo ========================================
    ) else (
        echo.
        echo ⚠ Push failed. Possible reasons:
        echo   1. Authentication required
        echo   2. Need to pull changes first: git pull origin %branch% --rebase
        echo   3. Network issues
    )
)

echo.
echo Done!
pause

