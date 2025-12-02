@echo off
echo ============================================
echo   Starting Python Backend for Local Testing
echo ============================================
echo.
cd /d "%~dp0Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"
echo Current directory: %CD%
echo.
echo Starting Flask server...
echo Server will run on: http://localhost:5000
echo.
echo Press CTRL+C to stop the server
echo ============================================
echo.
python app.py
pause

