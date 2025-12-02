@echo off
echo ========================================
echo Committing Chatbot Integration to GitHub
echo ========================================
echo.

echo Step 1: Adding chatbot files...
git add api/chatbot_helper.py
git add api/Chatbot/
git add api/app.py
git add lib/services/chatbot_service.dart
git add lib/screens/ai_stylist_screen.dart
git add lib/screens/admin/chatbot_review_screen.dart
git add lib/screens/admin/admin_dashboard_screen.dart
git add lib/main.dart
git add CHATBOT_SETUP.md
git add QUICK_START_CHATBOT.md
git add GIT_COMMIT_CHATBOT.md
git add .gitignore

echo.
echo Step 2: Checking status...
git status

echo.
echo Step 3: Committing changes...
git commit -m "Add complete chatbot integration for VogueAI Fashion Stylist

- Add chatbot_helper.py for Flask API integration
- Add Chatbot directory with training scripts and utilities
- Add chatbot endpoints (/chatbot/chat, /chatbot/health) to Flask API
- Add Flutter ChatbotService for API communication
- Add AI Stylist screen with chat interface
- Add admin chatbot review screen
- Update routes and navigation
- Add comprehensive documentation and setup guides"

echo.
echo Step 4: Pushing to GitHub...
git push

echo.
echo ========================================
echo Done! Check GitHub to verify upload.
echo ========================================
pause

