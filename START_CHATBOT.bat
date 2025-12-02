@echo off
echo ====================================
echo   Starting Flask API with Chatbot
echo ====================================
echo.

cd "Vogue-AI-Next-_-Gen-Fashion-Stylist-main\api"

echo Starting Flask server...
echo Chatbot will be available at:
echo   - http://localhost:5000/chatbot/chat
echo   - http://localhost:5000/chatbot/health
echo.
echo Press Ctrl+C to stop the server
echo.

python app.py

pause

