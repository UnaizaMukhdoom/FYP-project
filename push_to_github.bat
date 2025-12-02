@echo off
REM Batch script to push all code to GitHub
REM Run this from the project root directory

echo ========================================
echo VOGUE AI - Push to GitHub Script
echo ========================================
echo.

cd /d "%~dp0"

echo Current directory: %CD%
echo.

REM Check if git is initialized
if not exist ".git" (
    echo Git repository not found. Initializing...
    git init
    echo ✓ Git initialized
) else (
    echo ✓ Git repository found
)

echo.
echo Checking git status...
git status --short

echo.
echo Adding all files...
git add .

echo ✓ Files added
echo.

echo Files to be committed:
git status --short

echo.
set /p commitMessage="Enter commit message (or press Enter for default): "

if "%commitMessage%"=="" (
    set commitMessage=Update Vogue AI Fashion Stylist project - Complete codebase
)

echo.
echo Committing changes...
git commit -m "%commitMessage%"

if %errorlevel% neq 0 (
    echo ⚠ No changes to commit or commit failed
    echo.
    set /p continue="Do you want to continue and check remote? (Y/N): "
    if /i not "%continue%"=="Y" exit /b
)

echo.

REM Check remote
echo Checking remote repository...
git remote get-url origin >nul 2>&1

if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('git remote get-url origin') do set remoteUrl=%%i
    echo ✓ Remote found: %remoteUrl%
    echo.
    echo Pushing to GitHub...
    
    for /f "tokens=*" %%i in ('git branch --show-current') do set branch=%%i
    if "%branch%"=="" (
        set branch=main
        git branch -M main 2>nul
    )
    
    echo Branch: %branch%
    git push -u origin %branch%
    
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo ✓ Successfully pushed to GitHub!
        echo ========================================
    ) else (
        echo.
        echo ⚠ Push failed. Possible reasons:
        echo   1. Remote URL not configured
        echo   2. Authentication required
        echo   3. Branch doesn't exist on remote
        echo.
        echo To set up remote, run:
        echo   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
        echo.
        echo Then push with:
        echo   git push -u origin %branch%
    )
) else (
    echo ⚠ No remote repository configured
    echo.
    echo To add a remote repository, run:
    echo   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
    echo.
    set /p addRemote="Do you want to add a remote now? (Y/N): "
    
    if /i "%addRemote%"=="Y" (
        set /p repoUrl="Enter GitHub repository URL (e.g., https://github.com/username/repo.git): "
        if not "%repoUrl%"=="" (
            git remote add origin "%repoUrl%"
            echo ✓ Remote added
            echo.
            
            for /f "tokens=*" %%i in ('git branch --show-current') do set branch=%%i
            if "%branch%"=="" (
                set branch=main
                git branch -M main 2>nul
            )
            
            echo Pushing to GitHub...
            git push -u origin %branch%
            
            if %errorlevel% equ 0 (
                echo.
                echo ========================================
                echo ✓ Successfully pushed to GitHub!
                echo ========================================
            )
        )
    )
)

echo.
echo Done!
pause

