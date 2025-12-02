@echo off
echo ========================================
echo   Starting Virtual Wardrobe Backend
echo ========================================
echo.
cd /d "%~dp0Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
echo Current directory: %CD%
echo.
echo Starting Flask server...
echo.
python app.py
pause

