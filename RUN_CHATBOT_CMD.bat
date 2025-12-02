@echo off
echo ====================================
echo   Starting Flask API with Chatbot
echo ====================================
echo.

REM Navigate to the correct API directory
cd /d "%~dp0Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"

REM Check if directory exists
if not exist "app.py" (
    echo ERROR: app.py not found!
    echo Current directory: %CD%
    echo.
    echo Please make sure you're running this from the project root.
    pause
    exit /b 1
)

echo Current directory: %CD%
echo.
echo Starting Flask server...
echo Chatbot will be available at:
echo   - http://localhost:5000/chatbot/chat
echo   - http://localhost:5000/chatbot/health
echo.
echo Press Ctrl+C to stop the server
echo.

python app.py

pause

